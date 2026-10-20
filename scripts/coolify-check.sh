#!/usr/bin/env bash
# Verifica que el compose de este repo respeta el contrato minimo que exige
# Coolify para un despliegue detras de Traefik. Falla con "servicio: motivo".
#
# Contrato aplicado (resumen del plan):
#   1. Servicios sin profiles no pueden usar puertos publicados, container_name,
#      privileged, cap_add, devices, network_mode: host, pid/ipc: host,
#      security_opt: unconfined ni bind-mounts fuera del repo o de docker.sock.
#   2. No usar 'name:' fijo a nivel de proyecto ni en redes/volumenes
#      (Coolify asigna los suyos propios).
#   3. Si un servicio sin build propio referencia una imagen concreta con
#      pull_policy: never, algun otro servicio debe producir esa imagen con
#      build. Si no, Coolify no podra generarla y el arranque fallara.
#
# No lee .env reales ni secretos: genera un .env temporal con valores ficticios
# para que `docker compose config` pueda renderizar el YAML.

set -euo pipefail

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
compose_file="${repo_root}/compose.yaml"

if [[ ! -f "${compose_file}" ]]; then
    echo "compose: no se encontro ${compose_file}" >&2
    exit 2
fi

# Extrae los nombres de variables referenciadas como ${VAR} o ${VAR:?msg} / ${VAR:-def}
# en el YAML del raiz (cubre los servicios del compose actual).
variables="$(grep -oE '\$\{[A-Z_][A-Z0-9_]*[^}]*\}' "${compose_file}" \
    | sed -E 's/^\$\{([A-Z0-9_]+).*$/\1/' \
    | sort -u || true)"

# Genera .env temporal con valores ficticios:
#   - variables con HOST/DOMAIN/URL -> https://ejemplo.invalid (placeholder)
#   - el resto -> 32 caracteres hex ficticios
tmp_env="$(mktemp -t coolify-check.XXXXXX.env)"
trap 'rm -f "${tmp_env}"' EXIT
{
    for v in ${variables}; do
        case "${v}" in
            *HOST*|*DOMAIN*|*URL*)
                echo "${v}=https://ejemplo.invalid"
                ;;
            *)
                echo "${v}=x1234567890abcdef1234567890abcdef"
                ;;
        esac
    done
} > "${tmp_env}"

# Render del compose con el .env temporal. stderr va aparte: si el archivo de
# configuracion de docker no es legible, ese WARNING iria al JSON y rompe jq.
docker_err="$(mktemp -t coolify-check.XXXXXX.err)"
if ! render_json="$(docker compose \
        --project-directory "${repo_root}" \
        -f "${compose_file}" \
        --env-file "${tmp_env}" \
        config --format json 2>"${docker_err}")"; then
    echo "compose: no se pudo renderizar (faltan variables o sintaxis invalida):" >&2
    sed 's/^/  /' "${docker_err}" >&2 || true
    rm -f "${docker_err}"
    exit 3
fi
rm -f "${docker_err}"

errors=0

# --- Contrato 2: 'name:' fijo en el YAML fuente ---------------------------
# Compose auto-rellena project/network/volume names al renderizar aunque el
# fuente no los declare (usa el directorio como prefijo), asi que el chequeo
# debe mirar el YAML fuente, no el JSON renderizado.
name_violations="$(python3 - "${compose_file}" <<'PY'
import sys, yaml
src = sys.argv[1]
try:
    doc = yaml.safe_load(open(src))
except Exception as exc:
    print(f"compose: YAML invalido -> {exc}")
    sys.exit(0)
if not isinstance(doc, dict):
    sys.exit(0)
out = []
root_name = doc.get("name")
if isinstance(root_name, str) and root_name.strip():
    out.append(f"compose: project 'name' fijo '{root_name}' (Coolify asigna el suyo)")
for key, val in (doc.get("networks") or {}).items():
    if isinstance(val, dict):
        n = val.get("name")
        if isinstance(n, str) and n.strip():
            out.append(f"compose: red '{key}' con 'name:' fijo '{n}'")
for key, val in (doc.get("volumes") or {}).items():
    if isinstance(val, dict):
        n = val.get("name")
        if isinstance(n, str) and n.strip():
            out.append(f"compose: volumen '{key}' con 'name:' fijo '{n}'")
for line in out:
    print(line)
PY
)"
if [[ -n "${name_violations}" ]]; then
    echo "${name_violations}" >&2
    while IFS= read -r line; do
        errors=$((errors + 1))
    done <<< "${name_violations}"
fi

# --- Contrato 1: servicios sin profiles ----------------------------------
# Recorre servicios y aplica las claves prohibidas sobre los que no estan
# dentro de ningun profile (Coolify los levanta siempre).
forbidden_keys=(ports container_name privileged cap_add devices)
services_iter() {
    printf '%s' "${render_json}" \
        | jq -c '.services // {} | to_entries[]'
}
while IFS= read -r svc; do
    name="$(printf '%s' "${svc}" | jq -r '.key')"
    body="$(printf '%s' "${svc}" | jq -c '.value')"
    in_profile="$(printf '%s' "${body}" | jq -r '.profiles // [] | length')"
    if [[ "${in_profile}" != "0" ]]; then
        continue
    fi

    for key in "${forbidden_keys[@]}"; do
        present="$(printf '%s' "${body}" | jq -r --arg k "${key}" 'has($k)')"
        if [[ "${present}" == "true" ]]; then
            echo "${name}: clave prohibida '${key}' (rompe aislamiento Coolify)" >&2
            errors=$((errors + 1))
        fi
    done

    nm="$(printf '%s' "${body}" | jq -r '.network_mode // empty')"
    if [[ "${nm}" == "host" ]]; then
        echo "${name}: network_mode host no permitido" >&2
        errors=$((errors + 1))
    fi

    for k in pid ipc; do
        v="$(printf '%s' "${body}" | jq -r --arg k "${k}" '.[$k] // empty')"
        if [[ "${v}" == "host" ]]; then
            echo "${name}: ${k}=host no permitido" >&2
            errors=$((errors + 1))
        fi
    done

    sec="$(printf '%s' "${body}" \
        | jq -r '[.security_opt // [] | .[] | select(test("unconfined"))] | length')"
    if [[ "${sec}" != "0" ]]; then
        echo "${name}: security_opt unconfined no permitido" >&2
        errors=$((errors + 1))
    fi

    while IFS= read -r src; do
        [[ -z "${src}" ]] && continue
        if [[ "${src}" == *docker.sock* ]]; then
            echo "${name}: monta docker.sock ('${src}')" >&2
            errors=$((errors + 1))
        elif [[ "${src}" == /* && "${src}" != "${repo_root}/"* ]]; then
            echo "${name}: bind fuera del repo '${src}'" >&2
            errors=$((errors + 1))
        fi
    done < <(printf '%s' "${body}" \
        | jq -r --arg root "${repo_root}/" \
            '(.volumes // [])
            | map(select(.type=="bind") | .source)
            | .[]?')

    # --- Contrato 3: imagen sin build con pull_policy: never --------------
    image="$(printf '%s' "${body}" | jq -r '.image // empty')"
    pp="$(printf '%s' "${body}" | jq -r '.pull_policy // empty')"
    has_build="$(printf '%s' "${body}" | jq -r '.build // empty')"
    if [[ -n "${image}" && -z "${has_build}" && "${pp}" == "never" ]]; then
        produced="$(printf '%s' "${render_json}" \
            | jq -r --arg i "${image}" \
                '[.services | to_entries[]
                    | select(.value.build != null)
                    | (.value.image // "") as $img
                    | select($img == $i)] | length')"
        if [[ "${produced}" == "0" ]]; then
            echo "${name}: usa image '${image}' con pull_policy never sin build propio ni servicio que la produzca" >&2
            errors=$((errors + 1))
        fi
    fi
done < <(services_iter)

if [[ "${errors}" -gt 0 ]]; then
    echo "compose: ${errors} incumplimiento(s) del contrato Coolify" >&2
    exit 1
fi

echo "compose: contrato Coolify OK"
