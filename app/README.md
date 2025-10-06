# Betting API

This is a **simple betting backend API** built with **Elixir + Phoenix Framework**.  
It enables user registration, login, role-based access, game management by superusers, and user betting functionalities.

---

## Architecture Overview

The system is organized into **three main contexts** for clarity and modularity:

| Context | Responsibility |
|----------|----------------|
| `Accounts` | Handles user registration, authentication, and roles. |
| `Games` | Manages game creation, updates, results, and profit computation. |
| `Bets` | Handles bet placement, cancellation, listing, and settlement. |

### System Flow
1. Users register and log in.
2. Superusers create and manage games.
3. Users place bets on open games.
4. When a game is resolved, bets are settled automatically via a background queue.
5. Admins can view game profits and user details.

---

## Tech Stack

- **Language:** Elixir  
- **Framework:** Phoenix  
- **Database:** PostgreSQL  
- **ORM:** Ecto  
- **Background Processing:** GenServer (`BetSettlementQueue`)  
- **Serialization:** Jason JSON Encoder  
- **Authentication:** Token/session-based plug system  

---

## Setup Instructions

### 1. Clone & Install Dependencies
```bash
git clone https://github.com/dideey/Betting-system.git
cd app
mix deps.get
```
# 2. Database Setup
Ensure PostgreSQL is running and create the database:
```bash
mix ecto.create
mix ecto.migrate
```
### 3. Run the Server
```bash
mix phx.server
```
The API will be accessible at `http://localhost:4000`.

### User API Routes
| Method | Endpoint             | Description                             |
| ------ | -------------------- | --------------------------------------- |
| `POST` | `/api/auth/register` | Register a new user                     |
| `POST` | `/api/auth/login`    | Log in an existing user                 |
| `POST` | `/api/auth/logout`   | Log out user (invalidate token/session) |

Example Registration Request:

```bash
POST /api/auth/register
{
  "email": "john@example.com",
  "password": "secret123",
  "first_name": "John",
  "last_name": "Doe"
}

```
### Betting API Routes
| Method   | Endpoint        | Description                         |
| -------- | --------------- | ----------------------------------- |
| `POST`   | `/api/bets`     | Place a bet on an open game         |
| `GET`    | `/api/bets`     | List bets placed by current user    |
| `DELETE` | `/api/bets/:id` | Cancel an existing bet (if allowed) |

### Game Management API Routes
| Method   | Endpoint                           | Description                                        |
| -------- | ---------------------------------- | -------------------------------------------------- |
| `POST`   | `/api/superuser/games`             | Create a new game                                  |
| `GET`    | `/api/superuser/games`             | List all games                                     |
| `PUT`    | `/api/superuser/games/:id`         | Update game details or odds                        |
| `DELETE` | `/api/superuser/games/:id`         | Delete a game                                      |
| `POST`   | `/api/superuser/games/:id/resolve` | Mark a game as resolved and trigger bet settlement |
| `GET`    | `/api/superuser/games/:id/profit`  | Compute total profit (stakes - payouts) for a game |

### User Management API Routes
| Method   | Endpoint                        | Description                 |
| -------- | ------------------------------- | --------------------------- |
| `POST`   | `/api/superuser/users/:id/role` | Set or change a user's role |
| `DELETE` | `/api/superuser/users/:id`      | Soft delete a user          |
| `GET`    | `/api/superuser/users/:id`      | View user details           |

## Example API Flow
1. Register → Login → Get token/session

2. Superuser → Create game → Users place bets

3. Superuser → Resolve game → Settlement auto-triggers

4. Check bets → See win/loss statuses

5. Compute game profit


### Author
- Backend Developer: **Dideey** - [GitHub](https://github.com/dideey)
