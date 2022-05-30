module DataMock
  module Products
    def get_products
      [
        ['Tubo simple de ortodoncia p/ 2do. molar superior izquierdo', '10343'],
        ['Tubo simple de ortodoncia p/ 2do. molar superior izquierdo', '10342'],
        ['Sonda sengstaken blackenmore nº 14', '10292'],
        ['Sulfato de zinc 1% x200 ml. (Magistral)', '20812'],
        ['GAM-COVID-VAC C1 - Vial - 2 - Dosis - Biocad - Pharm UFAVITA', '11959'],
        ['Cable para ECG de 12 pines', '9587'],
        ['Catéter para hemodiálisis x52cm T/Tesio (alto flujo y baja articulación10 Fr)', '9769'],
        ['Sistema implantable para administración fármacos T/Lexel 9 Fr', '11027'],
        ['Acido Folico 5 mg/ml gotas', '10004'],
        ['Acido Salicilico 10% Lanovaselina (magistral)', '20813'],
        ['Sonda Urinaria lubricada para uso intermitente 6 Fr pediatrica Nelaton', '11312'],
        ['Bisoprolol 2.5 mg ', '11332'],
        ['Ciproterona + Etiniliestradiol por 21 comp', '10587'],
        ['Bolsa para ostomía', '20814'],
        ['Sonda Foley de 3 vías hematurica, con alma de acero N° 20', '11143'],
        ['Sonda Foley de 3 vías hematurica, con alma de acero N° 18', '11142'],
        ['Sistema flash de monitoreo de glucosa', '20815'],
        ['Hidrato de cloral al 10% por 50 ml (Magistral)', '20816'],
        ['Hidrocortisona 0.25% jarabe 100ml (Magistral)', '20817'],
        ['Hidroclorotiazida 0.5% suspensión 100 ml (Magistral)', '20818']
      ]
    end
  end
  
  module Patients
    def get_patients
      [
        ['57122312', 'Masculino', 'Quintulen Curruhinca', 'Gadiel Rafael', 'soltero'],
        ['56757987', 'Otro', 'Aguirre', 'Verónica', 'soltero'],
        ['29298088', 'Masculino', 'BAUER', 'GABRIEL', 'soltero'],
        ['56757352', 'Masculino', 'CHEUQUEPAN', 'EMILIO MACIEL', 'soltero'],
        ['57122317', 'Masculino', 'INAL SANGIULIANO', 'LORENZO NAHITAN', 'soltero']
      ]
    end
  end
end