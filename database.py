import pyodbc

#Es la clase encargada de la conexion de con la base de datos y de ejecutar los procedimientos de la misma
class BaseDeDatos:
    def __init__(self):
        try:
            self.conexion = pyodbc.connect(
                'DRIVER={ODBC Driver 17 for SQL Server};'
                'SERVER=PC-DEV14;'
                #'SERVER=LEONEL;'
                'DATABASE=Gestion_Operaciones_Bancarias;'
                'UID=Leonel;'
                'PWD=Leonel'
            )
            self.cursor = self.conexion.cursor()
        except pyodbc.Error as e:
            print("Error al conectar la base de datos",e)
            raise

        
    def ejecutar_consulta(self, consulta, parametros = None):
        try:
            if parametros:
                self.cursor.execute(consulta, parametros)
            else:
                self.cursor.execute(consulta)
            self.conexion.commit()
        except pyodbc.Error as e:
            print("Erro al ejecutar el procedimiento",e)
            raise

    def obtener_datos(self, consulta, parametros=None):
        try:
            cursor = self.conexion.cursor()
            if parametros is None:
                cursor.execute(consulta)
            else:
                cursor.execute(consulta, parametros)
            return cursor.fetchall()
        except Exception as e:
            print(f"Error al obtener datos: {e}")
            return None
        
    def cerrar_conexion(self):
        self.cursor.close()
        self.conexion.close()
