# 🎯 FLUJO COMPLETO ACTUALIZADO - PROVIDER SERVICES

## 📊 FLUJO GENERAL DE LA APP

```
┌─────────────────────────────────────────────────────────┐
│              APP INICIA - SplashPage                    │
│            (Muestra loading por 500ms)                  │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
        ┌────────────────────────────┐
        │    WelcomePage             │
        │  (Cliente vs Proveedor)    │
        └────┬────────────────────┬──┘
             │                    │
    ┌────────▼──┐        ┌──────▼────────┐
    │ "Crear    │        │ "Unirme como  │
    │  Fiesta"  │        │  Proveedor"   │
    └────┬──────┘        └──────┬────────┘
         │                      │
         ▼                      ▼
  ┌────────────────┐   ┌─────────────────┐
  │ClientLoginPage │   │ProviderLoginPage│
  └────┬───────────┘   └────┬────────────┘
       │                    │
       │[LOGIN EXITOSO]     │[LOGIN EXITOSO]
       │                    │
       ▼                    ▼
  ┌──────────┐         ┌──────────┐
  │ClientDash│         │ProviderD │
  │board     │         │ashboard  │
  └──────────┘         └────┬─────┘
                             │
                      [Click "Responder"]
                             │
                             ▼
                      ┌──────────────────┐
                      │ProviderServices  │
                      │Page (Detalles)   │
                      └────┬────────┬────┘
                           │        │
                   [Unirse │evento] │[Mis Eventos]
                           │        │
                           ▼        ▼
                        [evento]  HomeScreen
                        Added     (Mis Eventos)
```

---

## 🏠 FLUJO DETALLADO - HOMESCREEN (Mis Eventos)

### **Pantalla: HomeScreen - "Mis Eventos"**

**Header:**

- Título: "Festeasy"
- Buscador de eventos
- Color: Blanco con rojo para elementos activos

**Tabs de Filtro:**

- "Próximos" (activo - rojo)
- "Pasados"
- "Todos"

**Secciones:**

1. **"Próximos"** - Lista de eventos próximos
2. **"Pasados"** - Lista de eventos pasados

**Cada Evento en la Lista:**

```
┌─────────────────────────────────┐
│ [Imagen]  12 de julio           │
│           Fiesta de Verano      │
│           Casa de Alex          │
│                                 │
│           [Click para ver       │
│            detalles →           │
│            ProviderServices]    │
└─────────────────────────────────┘
```

**Bottom Navigation:**

- 🏠 Inicio (activo - rojo)
- 📅 Eventos
- 👤 Perfil
- ⚙️ Ajustes

**Botón Flotante:**

- ➕ Agregar evento (rojo, esquina inferior derecha)

---

## 🔄 FLUJO DE NAVEGACIÓN CON "MIS EVENTOS" BUTTON

```
ProviderServices
(Detalles del Evento)
│
├─ [Unirse al Evento]
│  └─> (Agregar evento)
│
└─ [Mis Eventos] ← BOTÓN CON ICONO DE CALENDARIO
   └─> HomeScreen (Lista completa de eventos del proveedor)
      │
      ├─ Próximos
      ├─ Pasados
      └─ Todos
         │
         [Click en evento]
         └─> ProviderServices (ver detalles nuevamente)
```

---

## 📱 ESTRUCTURA DE HOMESCREEN MEJORADA

```
┌─────────────────────────────────────┐
│ 🏠 Festeasy          [🔍 Buscar]   │ ← Header blanco
├─────────────────────────────────────┤
│ [Próximos] [Pasados] [Todos]       │ ← Tabs (rojo activo)
├─────────────────────────────────────┤
│ Próximos                            │
│                                     │
│ ┌──────────────────────────────┐   │
│ │ [IMG] 12 de julio            │   │
│ │       Fiesta de Verano       │   │
│ │       Casa de Alex           │   │
│ └──────────────────────────────┘   │
│       ↓ Click → ProviderServices   │
│                                     │
│ ┌──────────────────────────────┐   │
│ │ [IMG] 20 de agosto           │   │
│ │       Cumpleaños de Sofía    │   │
│ │       Restaurante La Luna    │   │
│ └──────────────────────────────┘   │
│       ↓ Click → ProviderServices   │
│                                     │
│ Pasados                             │
│ ┌──────────────────────────────┐   │
│ │ [IMG] 5 de mayo              │   │
│ │       Concierto de Rock      │   │
│ │       Estadio Central        │   │
│ └──────────────────────────────┘   │
│       ↓ Click → ProviderServices   │
│                                     │
├─────────────────────────────────────┤
│ 🏠 Inicio | 📅 Eventos | 👤 Perfil│ ← Nav inferior
└──────────────────────────────────────┘
     🔴 ➕ (botón flotante rojo)
```

---

## 🎨 COLORES Y ESTILOS

| Elemento            | Color            | Notas                 |
| ------------------- | ---------------- | --------------------- |
| Fondo               | Blanco (#FFFFFF) | Limpio                |
| Texto principal     | Rojo (#EA4D4D)   | Títulos, tabs activos |
| Texto secundario    | Gris (#999999)   | Subtítulos, ubicación |
| Tab activo          | Rojo (#EA4D4D)   | Con fondo             |
| Tab inactivo        | Gris (#CCCCCC)   | Sin fondo             |
| Botones             | Rojo (#EA4D4D)   | Flotante, acciones    |
| Icono "Mis Eventos" | 📅 Calendario    | SVG de calendario     |

---

## 🔘 ICONOS Y BOTONES

### **Botón "Mis Eventos" en ProviderServices**

```dart
Icon: 📅 (calendario)
Label: "Mis Eventos"
Color: Rojo (#EA4D4D)
Background: Rojo claro con transparencia
Action: Navega a HomeScreen
```

### **Bottom Navigation**

```
🏠 Inicio      - Red
📅 Eventos    - Gris
👤 Perfil     - Gris
⚙️ Ajustes    - Gris
```

### **Botón Flotante**

```
➕ (plus icon)
Color: Rojo (#EA4D4D)
Position: Bottom Right
Action: Agregar nuevo evento
```

---

## 📌 CAMBIOS A IMPLEMENTAR

### **1. HomeScreen**

- ✅ Ajustar layout para que se visualice correctamente
- ✅ Mejorar cards de eventos
- ✅ Agregar navegación al hacer click en eventos
- ✅ Botón flotante para agregar eventos

### **2. ProviderServices**

- ✅ Botón "Mis Eventos" con icono de calendario
- ✅ Color rojo y blanco
- ✅ Navega a HomeScreen

### **3. Navegación**

- ✅ Evento en lista → ProviderServices
- ✅ ProviderServices → HomeScreen (botón "Mis Eventos")
- ✅ HomeScreen → ProviderServices (click en evento)

---

## 🚀 FLUJO COMPLETO DE USUARIO PROVEEDOR

```
1. ProviderDashboard
   ↓ [Click "Responder"]
2. ProviderServices (Detalles del evento/servicio)
   ↓ [Click "Mis Eventos"]
3. HomeScreen (Lista de todos sus eventos)
   ├─ Próximos
   ├─ Pasados
   └─ Todos
   ↓ [Click en un evento]
4. ProviderServices (Detalles nuevamente)
   ↓ [Click "Mis Eventos"]
5. HomeScreen (Regresa a lista)
```

---

## ✨ CARACTERÍSTICAS PRINCIPALES

✅ Fondo blanco limpio
✅ Colores rojo (#EA4D4D) y blanco
✅ Navegación fluida entre pantallas
✅ Botón "Mis Eventos" con icono de calendario
✅ Cards mejorados para eventos
✅ Filtros funcionales (Próximos, Pasados, Todos)
✅ Bottom navigation con colores coherentes
✅ Botón flotante para agregar eventos
