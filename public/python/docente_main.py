import sys
import json
import pandas as pd
import matplotlib.pyplot as plt

datos_python = sys.stdin.read()
data = json.loads(datos_python)
df = pd.DataFrame(data)

df_promedio = df.groupby('ASIGNATURA')['NOTA'].mean().reset_index()
df_promedio = df_promedio.rename(columns={'Asignatura': 'Promedio'})

plt.bar(df_promedio['ASIGNATURA'],df_promedio['NOTA'])


# Generar numeros en lugar de nombres largos
etiquetas = ['1','2','3','4','5','6','7','8','9','10','11']
plt.xticks(range(len(etiquetas)), etiquetas)


plt.xlabel('ASIGNATURA')
plt.ylabel('NOTA')
plt.title('Promedio por Curso')

plt.ylim(bottom=min(df_promedio['NOTA']) - 1, top=max(df_promedio['NOTA']) + 1)

plt.savefig('./public/image/prom_cursos.png')
plt.close()
