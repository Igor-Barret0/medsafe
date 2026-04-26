---
tags:
  - flutter
  - mobile
  - medsafe
created: 2025-04-26
---

# 💊 Medsafe

> Aplicativo Flutter de gerenciamento de medicamentos para idosos, cuidadores e administradores.

O app envia lembretes locais no horário de cada medicamento e escala um alerta ao cuidador caso o idoso não confirme após N tentativas.

---

## 📋 Sumário

- [[#🚀 Como Rodar]]
- [[#🏗️ Arquitetura]]
- [[#👥 Roles de Usuário]]
- [[#✅ Funcionalidades]]
- [[#🔧 Backend — O que desenvolver]]
- [[#📦 Modelos de Dados]]
- [[#🌐 Endpoints Esperados]]
- [[#⚙️ Config e Ambiente]]
- [[#📚 Stack]]

---

## 🚀 Como Rodar

### Pré-requisitos

- Flutter SDK `^3.38.5` (stable)
- Android Studio ou VS Code com extensão Flutter
- Emulador Android (API 31+) ou dispositivo físico

### Passos

```bash
git clone https://github.com/Igor-Barret0/medsafe.git
cd medsafe
flutter pub get
flutter run
```

### Simular roles no login

> [!INFO] Enquanto não há backend, o role é inferido pelo e-mail no login.

| E-mail contém | Role |
| --- | --- |
| `cuidador` | Cuidador |
| `admin` | Admin |
| qualquer outro | Paciente |

- Senha: qualquer string com **8+ caracteres**
- Código de verificação (esqueci a senha): use `123456`

---

## 🏗️ Arquitetura

```text
lib/
├── core/
│   ├── constants/     # AppColors, AppStrings
│   ├── routes/        # GoRouter
│   ├── services/      # NotificationService
│   └── widgets/       # CustomTextField, AppLogo...
│
├── features/
│   ├── auth/
│   │   ├── domain/    # UserRole (enum)
│   │   └── presentation/
│   │       ├── controllers/  # AuthController (ChangeNotifier)
│   │       └── pages/        # login, register, forgot, verify, new password
│   │
│   ├── onboarding/    # 3 telas de onboarding (1ª abertura)
│   ├── splash/        # SplashPage
│   │
│   └── home/
│       ├── user/      # Fluxo paciente/idoso
│       │   ├── domain/       # Medication + enums
│       │   └── presentation/ # home, history, add_medication, settings...
│       │
│       ├── caregiver/ # Fluxo cuidador
│       │   ├── state/        # CaregiverElderlyStore (ValueNotifier)
│       │   └── presentation/ # home, history, elderly management, alert...
│       │
│       └── admin/     # 🚧 Stub — não desenvolvido
│
└── main.dart          # inicializa NotificationService → runApp
```

> [!NOTE] Gerenciamento de estado
>
> - **Provider** → `AuthController` (autenticação global)
> - **ValueNotifier** → `CaregiverElderlyStore` (lista de idosos)
> - **GoRouter** → navegação com redirecionamento por role

---

## 👥 Roles de Usuário

| Role | Valor na API | Descrição |
| --- | --- | --- |
| Paciente | `usuario` | Visualiza e confirma seus medicamentos |
| Cuidador | `cuidador` | Monitora idosos, recebe alertas de doses perdidas |
| Admin | `admin` | Gestão geral — ainda não implementado no frontend |

### Paciente

- Lista de medicamentos do dia com status (tomado / atrasado / pendente)
- Confirmação de dose tomada
- Cadastro e edição de medicamentos (horário, frequência, alertas, cuidador vinculado)
- Notificações locais automáticas no horário configurado
- Histórico de aderência
- Gerenciamento de perfil, senha, foto e notificações

### Cuidador

- Painel com todos os idosos monitorados
- Alerta quando idoso não confirma dose após N tentativas
- Gerenciamento de idosos (adicionar, editar, encerrar acompanhamento)
- Histórico de aderência por idoso

---

## ✅ Funcionalidades

### Frontend — concluído

- [x] Onboarding (3 telas)
- [x] Autenticação completa: login, cadastro, esqueci senha, código, nova senha, confirmação
- [x] Seleção de role no cadastro (Paciente / Cuidador)
- [x] LGPD: aceite obrigatório no cadastro
- [x] Roteamento por role (GoRouter redireciona para a home correta)
- [x] Home do paciente: medicamentos do dia, stats de aderência, alerta de estoque baixo
- [x] Adicionar/editar medicamento: nome, dose, horário (picker rolável), frequência, intervalo de alerta, máx. tentativas, cuidador opcional
- [x] Home do cuidador: lista de idosos com status e stats
- [x] Gerenciamento de idosos: adicionar, editar, detalhes, encerrar acompanhamento
- [x] Histórico: filtro por período e por idoso, aderência agrupada por dia
- [x] Notificações locais: agendamento automático, retentativas configuráveis, escalada ao cuidador
- [x] Configurações: toggles de notificação, suporte, termos, conta
- [x] `CaregiverAlertPage` — tela de alerta ao cuidador
- [x] `MedicationReminderPage` — tela de lembrete ao idoso

### Aguardando backend

- [ ] Persistência real (tudo em memória atualmente)
- [ ] Autenticação via API (JWT)
- [ ] Recuperação de senha via e-mail
- [ ] Sincronização de medicamentos entre dispositivos
- [ ] Vínculo cuidador ↔ idoso via backend
- [ ] Push notifications remotas (FCM) para alertas ao cuidador
- [ ] Histórico real de aderência
- [ ] Gestão de estoque
- [ ] Painel admin

---

## 🔧 Backend — O que desenvolver

> [!IMPORTANT] Ponto de entrada no código
> Todos os métodos com comentário `// TODO: replace with real API call` estão em:
> `lib/features/auth/presentation/controllers/auth_controller.dart`
> Os dados de medicamentos estão mockados diretamente em `UserHomePage` e `CaregiverElderlyStore`.

### Prioridade 1 — Autenticação

```text
POST /auth/login
POST /auth/register
POST /auth/password-reset/request   ← envia e-mail com código de 6 dígitos
POST /auth/password-reset/verify    ← valida o código
POST /auth/password-reset/confirm   ← salva nova senha
POST /auth/logout
GET  /auth/me                       ← retorna usuário autenticado
```

Resposta de login/registro deve incluir: `{ token, user: { id, name, email, phone, role } }`

### Prioridade 1 — Medicamentos

```text
GET    /medications
POST   /medications
PUT    /medications/:id
DELETE /medications/:id
PATCH  /medications/:id/confirm  ← registra dose como tomada
```

### Prioridade 1 — Histórico

```text
GET /medications/history?from=ISO8601&to=ISO8601&elderlyId=string
```

### Prioridade 1 — Idosos (Cuidador)

```text
GET    /caregiver/elderlies
POST   /caregiver/elderlies
PUT    /caregiver/elderlies/:id
DELETE /caregiver/elderlies/:id
GET    /caregiver/elderlies/:id/history
```

### Prioridade 1 — FCM Token (Push ao Cuidador)

> [!WARNING] Fluxo crítico
> Quando o idoso não confirmar após `maxAttempts` tentativas, o **backend** deve disparar um push via FCM para o dispositivo do cuidador vinculado. O app já tem `CaregiverAlertPage` pronta para receber esse alerta.

```text
PATCH /users/me/fcm-token   body: { "token": "..." }
```

### Prioridade 2 — Estoque

```text
GET   /medications/:id/stock
PATCH /medications/:id/stock  body: { "remaining": 10 }
```

### Prioridade 2 — Perfil

```text
GET   /users/me
PATCH /users/me
PATCH /users/me/email
PATCH /users/me/password
POST  /users/me/photo
```

---

## 📦 Modelos de Dados

### User

```json
{
  "id": "string",
  "name": "string",
  "email": "string",
  "phone": "string",
  "role": "usuario | cuidador | admin",
  "photoUrl": "string | null",
  "createdAt": "ISO8601"
}
```

### Medication

```json
{
  "id": "string",
  "userId": "string",
  "name": "string",
  "dose": "string",
  "time": "HH:mm",
  "frequency": "diario | duasVezesDia | tresVezesDia | semanalDom | semanalSeg | semanalTer | semanalQua | semanalQui | semanalSex | semanalSab | quinzenal | mensal",
  "alertInterval": "cincoMin | dezMin | quinzeMin | trintaMin | umaHora",
  "maxAttempts": "uma | duas | tres | quatro | cinco",
  "caregiverName": "string | null",
  "caregiverPhone": "string | null",
  "stockRemaining": "int | null",
  "status": "tomado | atrasado | pendente"
}
```

### MedicationEvent

```json
{
  "id": "string",
  "medicationId": "string",
  "medicationName": "string",
  "dose": "string",
  "scheduledAt": "ISO8601",
  "confirmedAt": "ISO8601 | null",
  "status": "tomado | atrasado | perdido",
  "attempt": "int"
}
```

### CaregiverElderly

```json
{
  "id": "string",
  "caregiverId": "string",
  "elderlyUserId": "string",
  "elderlyName": "string",
  "elderlyAge": "int",
  "contact": "string",
  "medicationCount": "int",
  "lastActivity": "ISO8601",
  "status": "active | inactive"
}
```

---

## 🌐 Endpoints Esperados

| Método | Endpoint | Descrição |
| --- | --- | --- |
| POST | `/auth/login` | Login |
| POST | `/auth/register` | Cadastro |
| POST | `/auth/password-reset/request` | Solicita código de recuperação |
| POST | `/auth/password-reset/verify` | Valida código de 6 dígitos |
| POST | `/auth/password-reset/confirm` | Define nova senha |
| POST | `/auth/logout` | Invalida token |
| GET | `/auth/me` | Dados do usuário autenticado |
| PATCH | `/users/me` | Atualiza nome/telefone |
| PATCH | `/users/me/email` | Troca e-mail |
| PATCH | `/users/me/password` | Troca senha |
| POST | `/users/me/photo` | Upload foto de perfil |
| PATCH | `/users/me/fcm-token` | Registra token FCM |
| GET | `/medications` | Lista medicamentos |
| POST | `/medications` | Cria medicamento |
| PUT | `/medications/:id` | Edita medicamento |
| DELETE | `/medications/:id` | Remove medicamento |
| PATCH | `/medications/:id/confirm` | Confirma dose tomada |
| GET | `/medications/history` | Histórico de aderência |
| PATCH | `/medications/:id/stock` | Atualiza estoque |
| GET | `/caregiver/elderlies` | Lista idosos do cuidador |
| POST | `/caregiver/elderlies` | Vincula idoso |
| PUT | `/caregiver/elderlies/:id` | Edita vínculo |
| DELETE | `/caregiver/elderlies/:id` | Encerra acompanhamento |
| GET | `/caregiver/elderlies/:id/history` | Histórico do idoso |

---

## ⚙️ Config e Ambiente

Quando a integração com o backend iniciar, criar `lib/core/config/api_config.dart`:

```dart
class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:3000', // localhost no emulador Android
  );
}
```

Passar no build:

```bash
flutter run --dart-define=API_BASE_URL=https://api.medsafe.com.br
```

> [!TIP] Emulador Android
> O endereço `10.0.2.2` é o alias do `localhost` da máquina host dentro do emulador Android. Use esse IP para testar com servidor local.

---

## 📚 Stack

| Camada | Tecnologia |
| --- | --- |
| Framework | Flutter 3.38.5 |
| Linguagem | Dart |
| Navegação | go_router |
| Estado | Provider + ValueNotifier |
| Notificações locais | flutter_local_notifications + timezone |
| Timezone do dispositivo | flutter_timezone |
| Armazenamento local | shared_preferences |
| Validação de e-mail | email_validator |
| Máscara de input | mask_text_input_formatter |
| Internacionalização | intl |
| Info do dispositivo | package_info_plus, device_info_plus |
