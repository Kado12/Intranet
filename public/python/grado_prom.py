import sys
import json
import pandas as pd
import matplotlib.pyplot as plt

datos_python = sys.stdin.read()
data = json.loads(datos_python)
df = pd.DataFrame(data)
estadisticas_notas = df['NOTA'].describe()
print(estadisticas_notas.to_json())

# Generar grafico de caja y bigote
categorias = df['SECCION'].unique()
datos_por_categoria = []

for categoria in categorias:
    datos_categoria = df[df['SECCION'] == categoria]['NOTA']
    datos_por_categoria.append(datos_categoria)

plt.figure(figsize=(8,6))
plt.boxplot(datos_por_categoria, labels=categorias)
plt.xlabel('SECCION')
plt.ylabel('NOTA')
plt.title('Distribución de Notas por Sección')
plt.grid(True)
plt.savefig('./public/image/grado_prom_box.png')
plt.close()




# Generar grafico de promedios

df_promedio = df.groupby('SECCION')['NOTA'].mean().reset_index()
df_promedio = df_promedio.rename(columns={'NOTA': 'PROMEDIO'})

plt.bar(df_promedio['SECCION'],df_promedio['PROMEDIO'])
plt.xlabel('SECCION')
plt.ylabel('PROMEDIO')
plt.title('Promedio por Seccion')

plt.ylim(bottom=min(df_promedio['PROMEDIO']) - 1, top=max(df_promedio['PROMEDIO']) + 1)

plt.savefig('./public/image/grado_prom.png')
plt.close()
