# Phase III — Logical Database Design (Data Dictionary)

Generated: 2025-12-06 18:03:34

## USERS

- Description: Stores both clients and freelancers basic identity and contact info.

| Column | Data Type / Constraints | Notes |
|---|---|---|
| user_id | NUMBER PK | Primary key |
| full_name | VARCHAR2(100) |  |
| email | VARCHAR2(100) UNIQUE |  |
| user_type | VARCHAR2(20) | ('CLIENT'|'FREELANCER'|'ADMIN') |
| created_at | DATE NOT NULL |  |


## FREELANCERS

- Description: Freelancer profile details linked to a user account.

| Column | Data Type / Constraints | Notes |
|---|---|---|
| freelancer_id | NUMBER PK |  |
| user_id | NUMBER FK -> USERS.user_id |  |
| bio | VARCHAR2(500) |  |


## SKILLS

- Description: Master list of skills/tags.

| Column | Data Type / Constraints | Notes |
|---|---|---|
| skill_id | NUMBER PK |  |
| skill_name | VARCHAR2(50) UNIQUE NOT NULL |  |


## FREELANCER_SKILLS

- Description: Associative table linking freelancers to skills (many-to-many).

| Column | Data Type / Constraints | Notes |
|---|---|---|
| freelancer_id | NUMBER FK -> FREELANCERS.freelancer_id |  |
| skill_id | NUMBER FK -> SKILLS.skill_id |  |
| PK | (freelancer_id, skill_id) composite PK |  |


## JOBS

- Description: Job postings created by clients.

| Column | Data Type / Constraints | Notes |
|---|---|---|
| job_id | NUMBER PK |  |
| client_id | NUMBER FK -> USERS.user_id |  |
| title | VARCHAR2(100) |  |
| description | VARCHAR2(1000) |  |
| budget | NUMBER(10,2) CHECK (budget > 0) |  |
| deadline | DATE CHECK (deadline > SYSDATE) |  |
| status | VARCHAR2(20) DEFAULT 'OPEN' |  |


## JOB_SKILLS

- Description: Associative table linking jobs to required skills.

| Column | Data Type / Constraints | Notes |
|---|---|---|
| job_id | NUMBER FK -> JOBS.job_id |  |
| skill_id | NUMBER FK -> SKILLS.skill_id |  |
| PK | (job_id, skill_id) composite PK |  |


## PROPOSALS

- Description: Freelancer applications to jobs with bid amounts and status.

| Column | Data Type / Constraints | Notes |
|---|---|---|
| proposal_id | NUMBER PK |  |
| job_id | NUMBER FK -> JOBS.job_id |  |
| freelancer_id | NUMBER FK -> FREELANCERS.freelancer_id |  |
| bid_amount | NUMBER(10,2) NOT NULL |  |
| proposal_date | DATE DEFAULT SYSDATE |  |
| status | VARCHAR2(20) DEFAULT 'PENDING' |  |


## CONTRACTS

- Description: Formalized agreement created when a proposal is accepted.

| Column | Data Type / Constraints | Notes |
|---|---|---|
| contract_id | NUMBER PK |  |
| job_id | NUMBER FK -> JOBS.job_id |  |
| freelancer_id | NUMBER FK -> FREELANCERS.freelancer_id |  |
| start_date | DATE |  |
| end_date | DATE |  |
| status | VARCHAR2(20) DEFAULT 'ACTIVE' |  |


## RATINGS

- Description: Client ratings for completed contracts.

| Column | Data Type / Constraints | Notes |
|---|---|---|
| rating_id | NUMBER PK |  |
| contract_id | NUMBER FK -> CONTRACTS.contract_id |  |
| score | NUMBER(1) CHECK (score BETWEEN 1 AND 5) |  |
| feedback | VARCHAR2(500) |  |


## Normalization & Assumptions

- Schema uses associative tables for many-to-many relationships.
- Non-key attributes depend on primary keys only (3NF).

- Assumptions:
  - USERS table holds all user accounts; role-specific data lives in FREELANCERS.
  - Email uniqueness enforced at DB level.
  - Audit/history tables are out of scope but recommended for production.
