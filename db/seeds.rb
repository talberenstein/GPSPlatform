# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

User.create email: "admin@gestsol.com", company_id: nil, role: "global_admin", password: "12345678", password_confirmation: "12345678"

Event.create name: "Reporte", syrus: "30", tk103: "tracker"
Event.create name: "Panico", syrus: "01", tk103: "help me"
Event.create name: "Bateria Baja", syrus: "02", tk103: "low battery"
Event.create name: "Corte Alimentacion Principal", syrus: "03", tk103: "ac alarm"
Event.create name: "Restablecimiento de Alimentacion Principal", syrus: "04"
Event.create name: "Motor Encendido", syrus: "05", tk103: "acc on"
Event.create name: "Motor Detenido", syrus: "06", tk103: "acc off"
Event.create name: "Puerta de Cabina Abierta", syrus: "07"
Event.create name: "Puerta de Cabina Cerrada", syrus: "08"
Event.create name: "Desenganche", syrus: "09"
Event.create name: "Puerta de Carga Abierta", syrus: "10"
Event.create name: "Puerta de Carga Cerrada", syrus: "11"
Event.create name: "Reporte Detenido", syrus: "31"
Event.create name: "Exceso de Velocidad", syrus: "12"
Event.create name: "Fin de Exceso de Velocidad", syrus: "13"
Event.create name: "Entrada a Geo Zona", syrus: "100", tk103: "enter_geo_zone"
Event.create name: "Salida de Geo Zona", syrus: "101", tk103: "exit_geo_zone"