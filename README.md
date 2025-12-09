# PL-SQL_Project

---

# Freelance Service Matching System (FSMS) — PL/SQL Capstone Project

A complete backend implementation of a **freelancer–client matching platform** built entirely with **Oracle SQL & PL/SQL**.
This system simulates a real-world marketplace (like Upwork or Fiverr) by managing:

* Users (clients & freelancers)
* Skills
* Job postings
* Proposals
* Contracts
* Ratings
* An intelligent **freelancer-job matching algorithm**

The project includes a full database schema, sequences, triggers, and a PL/SQL package for automated matching.

---

## 📁 Project Structure

```
📦 FSMS-PLSQL
 ├── fsms_full.sql          # Full SQL script (schema, triggers, package, tests)
 ├── README.md              # Project documentation
```

---

## 🚀 Features

### ✔ User Management

* Register clients and freelancers
* Freelancer profiles with rate, bio, skills

### ✔ Skills & Job Requirements

* Many-to-many skill mapping
* Jobs require specific skill sets

### ✔ Proposals, Contracts & Ratings

* Freelancers submit proposals with bids
* Clients create contracts
* Ratings after job completion

### ✔ Smart Matching Algorithm (PL/SQL Package)

The package `PKG_MATCHING` computes:

1. **Skill Match Ratio**
2. **Freelancer Rating Score**
3. **Bid-to-Budget Factor**

Produces a **0–100 score** ranking how suitable each freelancer is for a job.

---

## 🛠 Database Schema Overview

Core tables:

| Table               | Purpose                            |
| ------------------- | ---------------------------------- |
| `USERS`             | Clients & freelancers              |
| `FREELANCERS`       | Freelancer profiles                |
| `SKILLS`            | Skill catalog                      |
| `FREELANCER_SKILLS` | Mapping freelancer → skills        |
| `JOBS`              | Jobs posted by clients             |
| `JOB_SKILLS`        | Skills required for each job       |
| `PROPOSALS`         | Freelancer bids                    |
| `CONTRACTS`         | Active/closed contracts            |
| `RATINGS`           | Client ratings for freelancer work |

---

## 🔧 Sequences & Triggers

Each table uses auto-incremented primary keys via sequences:

```
SEQ_USERS, SEQ_FREELANCERS, SEQ_SKILLS,
SEQ_JOBS, SEQ_PROPOSALS, SEQ_CONTRACTS, SEQ_RATINGS
```

Triggers automatically assign sequence values before insert.

---

## 📦 Matching Package (PKG_MATCHING)

### `compute_match_score(job_id, freelancer_id, bid_amount)`

Returns a normalized (0–100) suitability score.

### `find_top_matches(job_id, limit)`

* Computes scores for all freelancers
* Ranks them
* Prints top N results via **DBMS_OUTPUT**

---

## 🧪 Testing

Enable DBMS Output:

```
View → DBMS Output → + → Select Connection
```

Run in SQL Worksheet:

```sql
SET SERVEROUTPUT ON;

BEGIN
  pkg_matching.find_top_matches(1, 5);
END;
/
```

Expected output example:

```
Top matches for job 1
Rank 1: Freelancer=3 | John Doe | Score=87.5
Rank 2: Freelancer=5 | Sarah B | Score=79.1
...
```

---

## ▶️ How to Run the Project

1. Connect to Oracle PDB (`FSMS_USER`)
2. Enable DBMS Output
3. Execute the main script:

```sql
@fsms_full.sql
```

4. Run test block to view match results

---

## 📌 Requirements

* Oracle Database **19c or later**
* SQL Developer or SQL*Plus
* Execute inside **PDB**, not the CDB
* User with `CREATE SESSION`, `CREATE TABLE`, `CREATE PROCEDURE`, etc.

---

## 📈 Future Enhancements (Optional)

* Add client dashboards via Oracle APEX
* Add machine learning–based job recommendations
* REST API integration with ORDS
* Web UI using React / Node.js / Spring Boot
* Freelancer availability and scheduling

---

## ✨ Author

**Sadé George Sadé**
Capstone Project — PL/SQL Database Development

---

