#!/usr/bin/env python3
import os,secrets
from pathlib import Path
root=Path(__file__).resolve().parent.parent
keys={'ADMIN_PASSWORD','DB_PASSWORD','DB_ROOT_PASSWORD'}
lines=[]
for line in (root/'.env.example').read_text().splitlines():
 key=line.split('=',1)[0]
 lines.append(key+'='+secrets.token_hex(32) if key in keys else line)
fd=os.open(root/'.env',os.O_WRONLY|os.O_CREAT|os.O_EXCL,0o600)
with os.fdopen(fd,'w') as f:f.write('\n'.join(lines)+'\n')
print('.env creado con permisos privados. Completar dominio, correo y proxy. No compartir secretos.')
