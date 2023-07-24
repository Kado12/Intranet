import sys
import json
import pandas as pd
import matplotlib.pyplot as plt

datos_python = sys.stdin.read()
data = json.loads(datos_python)
df = pd.DataFrame(data)

# describe
estadisticas_notas = df['NOTA'].describe()
print(estadisticas_notas.to_json())

df_promedio = df.groupby('PROFESOR')['NOTA'].mean().reset_index()
df_promedio = df_promedio.rename(columns={'Docente': 'Promedio'})

df_promedio = df_promedio.sort_values(by='PROFESOR')

plt.bar(df_promedio['PROFESOR'],df_promedio['NOTA'])

# Generar numeros en lugar de nombres largos
etiquetas = ['1','2','3','4','5']
plt.xticks(range(len(etiquetas)), etiquetas)

plt.xlabel('DOCENTE')
plt.ylabel('PROMEDIO')
plt.title('Promedio por Docente')

plt.ylim(bottom=min(df_promedio['NOTA']) - 1, top=max(df_promedio['NOTA']) + 1)

plt.savefig('./public/image/prom_doce_asig.png')
plt.close()
