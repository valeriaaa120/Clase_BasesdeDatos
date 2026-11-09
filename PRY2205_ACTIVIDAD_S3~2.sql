/*CASO 1 */

SELECT
    UPPER((SELECT tp.desc_tipo_propiedad
           FROM tipo_propiedad tp
           WHERE tp.id_tipo_propiedad = p.id_tipo_propiedad))
           AS "TIPO PROPIEDAD",

    COUNT(p.nro_propiedad)
           AS "CANTIDAD PROPIEDADES",

    TO_CHAR(MAX(NVL(p.valor_arriendo, 0)),
            '$999G999G990',
            'NLS_NUMERIC_CHARACTERS='',.''')
           AS "VALOR MAXIMO ARRIENDO",

    TO_CHAR(MIN(NVL(p.valor_arriendo, 0)),
            '$999G999G990',
            'NLS_NUMERIC_CHARACTERS='',.''')
           AS "VALOR MINIMO ARRIENDO",

    TO_CHAR(ROUND(AVG(NVL(p.valor_arriendo, 0))),
            '$999G999G990',
            'NLS_NUMERIC_CHARACTERS='',.''')
           AS "PROMEDIO ARRIENDO",

    CASE
        WHEN MAX(NVL(p.valor_arriendo, 0)) <= 1000000
            THEN 'ESTANDAR'
        ELSE 'PREMIUM'
    END AS "CLASIFICACION",

    TO_CHAR(SUM(NVL(p.valor_gasto_comun, 0)),
            '$999G999G990',
            'NLS_NUMERIC_CHARACTERS='',.''')
           AS "TOTAL GASTO COMUN"

FROM propiedad p

GROUP BY p.id_tipo_propiedad

HAVING SUM(NVL(p.valor_gasto_comun, 0)) > &VALOR_TOTAL_GASTO_COMUN

ORDER BY SUM(NVL(p.valor_gasto_comun, 0)) DESC;

/*CASO 2*/

SELECT
    TO_CHAR(e.numrut_emp, 'FM999G999G990') || '-' ||
    UPPER(e.dvrut_emp) AS "RUT EMPLEADO",

    INITCAP(
        TRIM(
            e.nombre_emp || ' ' ||
            e.appaterno_emp || ' ' ||
            NVL(e.apmaterno_emp, '')
        )
    ) AS "NOMBRE EMPLEADO",

    TO_CHAR(e.fecing_emp, 'DD/MM/YYYY') AS "FECHA INGRESO",

    TRUNC(MONTHS_BETWEEN(SYSDATE, e.fecing_emp) / 12)
        AS "ANIOS DE SERVICIO",

    TO_CHAR(
        NVL(e.sueldo_emp, 0),
        '$999G999G990',
        'NLS_NUMERIC_CHARACTERS='',.'''
    ) AS "SUELDO",

    CASE
        WHEN NVL(e.sueldo_emp, 0) > 2000000
            THEN 'ALTO'
        ELSE 'MEDIO'
    END AS "NIVEL SUELDO",

    TO_CHAR(
        ROUND(
            NVL(e.sueldo_emp, 0) *
            CASE
                WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, e.fecing_emp) / 12)
                     BETWEEN 5 AND 10
                    THEN 0.05

                WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, e.fecing_emp) / 12)
                     BETWEEN 11 AND 20
                    THEN 0.10

                WHEN TRUNC(MONTHS_BETWEEN(SYSDATE, e.fecing_emp) / 12)
                     > 20
                    THEN 0.15

                ELSE 0
            END
        ),
        '$999G999G990',
        'NLS_NUMERIC_CHARACTERS='',.'''
    ) AS "BONO ANTIGUEDAD"

FROM empleado e

WHERE e.id_categoria_emp = 3
  AND e.id_sucursal <> &CODIGO_SUCURSAL
  AND MONTHS_BETWEEN(SYSDATE, e.fecing_emp) > 60

ORDER BY e.sueldo_emp DESC;

/*CASO3*/

SELECT
    UPPER(clasificacion) AS "CLASIFICACION RENTA",

    TO_CHAR(COUNT(*), 'FM999G990')
        AS "CANTIDAD DE CLIENTES",

    TO_CHAR(
        ROUND(AVG(renta_cli)),
        '$999G999G990',
        'NLS_NUMERIC_CHARACTERS='',.'''
    ) AS "PROMEDIO DE RENTA",

    CASE
        WHEN MAX(
            CASE
                WHEN NVL(fonofijo_cli, 0) > 0
                  OR NVL(celular_cli, 0) > 0
                    THEN 1
                ELSE 0
            END
        ) = 1
            THEN 'CLIENTES CON TELEFONO'
        ELSE 'CLIENTES SIN TELEFONO'
    END AS "ESTADO TELEFONICO"

FROM (
    SELECT
        renta_cli,
        fonofijo_cli,
        celular_cli,

        CASE
            WHEN NVL(renta_cli, 0) >= 1000000
                THEN 'PREMIUM'

            WHEN NVL(renta_cli, 0) >= 600000
                THEN 'ALTA'

            WHEN NVL(renta_cli, 0) >= 300000
                THEN 'MEDIA'

            ELSE 'BAJA'
        END AS clasificacion

    FROM cliente
)

GROUP BY clasificacion

HAVING AVG(renta_cli) > 200000

ORDER BY AVG(renta_cli) DESC;

