import pandas as pd
from sqlalchemy import create_engine
import matplotlib.pyplot as plt

engine = create_engine('mysql+mysqlconnector://root:kado12@localhost/db_colegio')
ids_grado = ["(1,2,3,4)","(5,6,7,8)","(9,10,11,12)","(13,14,15,16)","(17,18,19,20)"]
main_df = pd.DataFrame(columns=["promedios"])
for grado in ids_grado:
    # Conseguir los alumnos del primer grado
    pre = pd.read_sql(f'SELECT * FROM estudiante WHERE crs_id IN {grado}', con=engine)
    # Guardar los id de los alumnos de primer grado
    alumnos = pre['est_usr_id'].tolist()
    # Chapar las notas de cada alumno de primer grado
    promedio_alumnos = []
    for alumno in alumnos:
        df = pd.read_sql(f'SELECT not_calificacion FROM nota_alumno WHERE est_usr_id = {alumno}', con=engine)
        promedio_alumnos.append(df['not_calificacion'].mean())
    # Promedio de cada alumno del grado
    df1 = pd.DataFrame(promedio_alumnos)
    # Promedio de todo el grado
    general_mean = df1[0].mean()
    main_df.loc[len(main_df)] = [general_mean]
    main_df = main_df.rename(index={0: 'Primer Grado', 1:'Segundo Grado', 2:'Tercer Grado', 3:'Cuarto Grado', 4:'Quinto Grado'})
print(main_df)
plt.plot(main_df['promedios'])
plt.title('Promedio por Grados')
plt.xlabel('Grados')
plt.ylabel('Promedios')
plt.savefig('./public/image/general_mean.png')
