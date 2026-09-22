-- Task: Standardize country labels for reporting
-- Preserve the original Spanish country name while adding
-- an English display name and ISO two-letter country code.

ALTER TABLE dim_location
    ADD COLUMN order_country_english VARCHAR(100)
        AFTER order_country,
    ADD COLUMN order_country_code CHAR(2)
        AFTER order_country_english;

DESCRIBE dim_location;

-- Create a reusable reference table for country standardization
CREATE TABLE IF NOT EXISTS ref_country_translation (
    original_country_name VARCHAR(100) PRIMARY KEY,
    english_country_name VARCHAR(100) NOT NULL,
    country_code CHAR(2) NOT NULL
)
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

DESCRIBE ref_country_translation;

INSERT INTO ref_country_translation
    (original_country_name, english_country_name, country_code)
VALUES
    ('Afganistán', 'Afghanistan', 'AF'),
    ('Albania', 'Albania', 'AL'),
    ('Alemania', 'Germany', 'DE'),
    ('Angola', 'Angola', 'AO'),
    ('Arabia Saudí', 'Saudi Arabia', 'SA'),
    ('Argelia', 'Algeria', 'DZ'),
    ('Argentina', 'Argentina', 'AR'),
    ('Armenia', 'Armenia', 'AM'),
    ('Australia', 'Australia', 'AU'),
    ('Austria', 'Austria', 'AT'),
    ('Azerbaiyán', 'Azerbaijan', 'AZ'),
    ('Bangladés', 'Bangladesh', 'BD'),
    ('Barbados', 'Barbados', 'BB'),
    ('Baréin', 'Bahrain', 'BH'),
    ('Bélgica', 'Belgium', 'BE'),
    ('Belice', 'Belize', 'BZ'),
    ('Benín', 'Benin', 'BJ'),
    ('Bielorrusia', 'Belarus', 'BY'),
    ('Bolivia', 'Bolivia', 'BO'),
    ('Bosnia y Herzegovina', 'Bosnia and Herzegovina', 'BA'),
    ('Botsuana', 'Botswana', 'BW'),
    ('Brasil', 'Brazil', 'BR'),
    ('Bulgaria', 'Bulgaria', 'BG'),
    ('Burkina Faso', 'Burkina Faso', 'BF'),
    ('Burundi', 'Burundi', 'BI'),
    ('Bután', 'Bhutan', 'BT'),
    ('Camboya', 'Cambodia', 'KH'),
    ('Camerún', 'Cameroon', 'CM'),
    ('Canada', 'Canada', 'CA'),
    ('Chad', 'Chad', 'TD'),
    ('Chile', 'Chile', 'CL'),
    ('China', 'China', 'CN'),
    ('Chipre', 'Cyprus', 'CY'),
    ('Colombia', 'Colombia', 'CO'),
    ('Corea del Sur', 'South Korea', 'KR'),
    ('Costa de Marfil', 'Côte d''Ivoire', 'CI'),
    ('Costa Rica', 'Costa Rica', 'CR'),
    ('Croacia', 'Croatia', 'HR'),
    ('Cuba', 'Cuba', 'CU'),
    ('Dinamarca', 'Denmark', 'DK'),
    ('Ecuador', 'Ecuador', 'EC'),
    ('Egipto', 'Egypt', 'EG'),
    ('El Salvador', 'El Salvador', 'SV'),
    ('Emiratos Árabes Unidos', 'United Arab Emirates', 'AE'),
    ('Eritrea', 'Eritrea', 'ER'),
    ('Eslovaquia', 'Slovakia', 'SK'),
    ('Eslovenia', 'Slovenia', 'SI'),
    ('España', 'Spain', 'ES'),
    ('Estados Unidos', 'United States', 'US'),
    ('Estonia', 'Estonia', 'EE'),
    ('Etiopía', 'Ethiopia', 'ET'),
    ('Filipinas', 'Philippines', 'PH'),
    ('Finlandia', 'Finland', 'FI'),
    ('Francia', 'France', 'FR'),
    ('Gabón', 'Gabon', 'GA'),
    ('Georgia', 'Georgia', 'GE'),
    ('Ghana', 'Ghana', 'GH'),
    ('Grecia', 'Greece', 'GR'),
    ('Guadalupe', 'Guadeloupe', 'GP'),
    ('Guatemala', 'Guatemala', 'GT'),
    ('Guayana Francesa', 'French Guiana', 'GF'),
    ('Guinea', 'Guinea', 'GN'),
    ('Guinea Ecuatorial', 'Equatorial Guinea', 'GQ'),
    ('Guinea-Bissau', 'Guinea-Bissau', 'GW'),
    ('Guyana', 'Guyana', 'GY'),
    ('Haití', 'Haiti', 'HT'),
    ('Honduras', 'Honduras', 'HN'),
    ('Hong Kong', 'Hong Kong', 'HK'),
    ('Hungría', 'Hungary', 'HU'),
    ('India', 'India', 'IN'),
    ('Indonesia', 'Indonesia', 'ID'),
    ('Irak', 'Iraq', 'IQ'),
    ('Irán', 'Iran', 'IR'),
    ('Irlanda', 'Ireland', 'IE'),
    ('Israel', 'Israel', 'IL'),
    ('Italia', 'Italy', 'IT'),
    ('Jamaica', 'Jamaica', 'JM'),
    ('Japón', 'Japan', 'JP'),
    ('Jordania', 'Jordan', 'JO'),
    ('Kazajistán', 'Kazakhstan', 'KZ'),
    ('Kenia', 'Kenya', 'KE'),
    ('Kirguistán', 'Kyrgyzstan', 'KG'),
    ('Kuwait', 'Kuwait', 'KW'),
    ('Laos', 'Laos', 'LA'),
    ('Lesoto', 'Lesotho', 'LS'),
    ('Líbano', 'Lebanon', 'LB'),
    ('Liberia', 'Liberia', 'LR'),
    ('Libia', 'Libya', 'LY'),
    ('Lituania', 'Lithuania', 'LT'),
    ('Luxemburgo', 'Luxembourg', 'LU'),
    ('Macedonia', 'North Macedonia', 'MK'),
    ('Madagascar', 'Madagascar', 'MG'),
    ('Malasia', 'Malaysia', 'MY'),
    ('Mali', 'Mali', 'ML'),
    ('Marruecos', 'Morocco', 'MA'),
    ('Martinica', 'Martinique', 'MQ'),
    ('Mauritania', 'Mauritania', 'MR'),
    ('México', 'Mexico', 'MX'),
    ('Moldavia', 'Moldova', 'MD'),
    ('Mongolia', 'Mongolia', 'MN'),
    ('Montenegro', 'Montenegro', 'ME'),
    ('Mozambique', 'Mozambique', 'MZ'),
    ('Myanmar (Birmania)', 'Myanmar', 'MM'),
    ('Namibia', 'Namibia', 'NA'),
    ('Nepal', 'Nepal', 'NP'),
    ('Nicaragua', 'Nicaragua', 'NI'),
    ('Níger', 'Niger', 'NE'),
    ('Nigeria', 'Nigeria', 'NG'),
    ('Noruega', 'Norway', 'NO'),
    ('Nueva Zelanda', 'New Zealand', 'NZ'),
    ('Omán', 'Oman', 'OM'),
    ('Países Bajos', 'Netherlands', 'NL'),
    ('Pakistán', 'Pakistan', 'PK'),
    ('Panamá', 'Panama', 'PA'),
    ('Papúa Nueva Guinea', 'Papua New Guinea', 'PG'),
    ('Paraguay', 'Paraguay', 'PY'),
    ('Perú', 'Peru', 'PE'),
    ('Polonia', 'Poland', 'PL'),
    ('Portugal', 'Portugal', 'PT'),
    ('Qatar', 'Qatar', 'QA'),
    ('Reino Unido', 'United Kingdom', 'GB'),
    ('República Centroafricana', 'Central African Republic', 'CF'),
    ('República Checa', 'Czechia', 'CZ'),
    ('República de Gambia', 'The Gambia', 'GM'),
    ('República del Congo', 'Republic of the Congo', 'CG'),
    ('República Democrática del Congo', 'Democratic Republic of the Congo', 'CD'),
    ('República Dominicana', 'Dominican Republic', 'DO'),
    ('Ruanda', 'Rwanda', 'RW'),
    ('Rumania', 'Romania', 'RO'),
    ('Rusia', 'Russia', 'RU'),
    ('Sáhara Occidental', 'Western Sahara', 'EH'),
    ('Senegal', 'Senegal', 'SN'),
    ('Serbia', 'Serbia', 'RS'),
    ('Sierra Leona', 'Sierra Leone', 'SL'),
    ('Singapur', 'Singapore', 'SG'),
    ('Siria', 'Syria', 'SY'),
    ('Somalia', 'Somalia', 'SO'),
    ('Sri Lanka', 'Sri Lanka', 'LK'),
    ('Suazilandia', 'Eswatini', 'SZ'),
    ('SudAfrica', 'South Africa', 'ZA'),
    ('Sudán', 'Sudan', 'SD'),
    ('Sudán del Sur', 'South Sudan', 'SS'),
    ('Suecia', 'Sweden', 'SE'),
    ('Suiza', 'Switzerland', 'CH'),
    ('Surinam', 'Suriname', 'SR'),
    ('Tailandia', 'Thailand', 'TH'),
    ('Taiwán', 'Taiwan', 'TW'),
    ('Tanzania', 'Tanzania', 'TZ'),
    ('Tayikistán', 'Tajikistan', 'TJ'),
    ('Togo', 'Togo', 'TG'),
    ('Trinidad y Tobago', 'Trinidad and Tobago', 'TT'),
    ('Túnez', 'Tunisia', 'TN'),
    ('Turkmenistán', 'Turkmenistan', 'TM'),
    ('Turquía', 'Turkey', 'TR'),
    ('Ucrania', 'Ukraine', 'UA'),
    ('Uganda', 'Uganda', 'UG'),
    ('Uruguay', 'Uruguay', 'UY'),
    ('Uzbekistán', 'Uzbekistan', 'UZ'),
    ('Venezuela', 'Venezuela', 'VE'),
    ('Vietnam', 'Vietnam', 'VN'),
    ('Yemen', 'Yemen', 'YE'),
    ('Yibuti', 'Djibouti', 'DJ'),
    ('Zambia', 'Zambia', 'ZM'),
    ('Zimbabue', 'Zimbabwe', 'ZW');
    
SELECT
    (SELECT COUNT(*)
     FROM ref_country_translation) AS mapped_countries,

    (SELECT COUNT(DISTINCT order_country)
     FROM dim_location) AS source_countries;
     
-- Populate the standardized country columns
UPDATE dim_location AS dl
INNER JOIN ref_country_translation AS rct
    ON dl.order_country COLLATE utf8mb4_unicode_ci
       = rct.original_country_name COLLATE utf8mb4_unicode_ci
SET
    dl.order_country_english = rct.english_country_name,
    dl.order_country_code = rct.country_code
WHERE dl.location_id > 0;

SELECT COUNT(*) AS locations_missing_country_mapping
FROM dim_location
WHERE order_country_english IS NULL
   OR order_country_code IS NULL;
   
ALTER TABLE dim_location
    MODIFY COLUMN order_country_english VARCHAR(100) NOT NULL,
    MODIFY COLUMN order_country_code CHAR(2) NOT NULL;
    
DESCRIBE dim_location;