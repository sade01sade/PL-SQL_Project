
-- =========================================================
--  FREELANCE SERVICE MATCHING SYSTEM - FULL SQL SCRIPT
--  Includes:
--   • Schema (tables)
--   • Sequences
--   • Triggers
--   • Package Specification & Body
--   • Test Script
-- =========================================================

-- ===========================
-- 1. SEQUENCES
-- ===========================
CREATE SEQUENCE seq_users START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_freelancers START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_skills START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_jobs START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_proposals START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_contracts START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE seq_ratings START WITH 1 INCREMENT BY 1;

-- ===========================
-- 2. TABLES
-- ===========================

CREATE TABLE users (
  user_id NUMBER PRIMARY KEY,
  full_name VARCHAR2(150) NOT NULL,
  email VARCHAR2(200) UNIQUE NOT NULL,
  user_type VARCHAR2(20) CHECK (user_type IN ('CLIENT','FREELANCER')),
  created_at DATE DEFAULT SYSDATE NOT NULL
);

CREATE TABLE freelancers (
  freelancer_id NUMBER PRIMARY KEY,
  user_id NUMBER NOT NULL,
  bio VARCHAR2(500),
  hourly_rate NUMBER(10,2),
  CONSTRAINT fk_freelancer_user FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE skills (
  skill_id NUMBER PRIMARY KEY,
  skill_name VARCHAR2(100) NOT NULL
);

CREATE TABLE freelancer_skills (
  freelancer_id NUMBER,
  skill_id NUMBER,
  PRIMARY KEY (freelancer_id, skill_id),
  FOREIGN KEY (freelancer_id) REFERENCES freelancers(freelancer_id),
  FOREIGN KEY (skill_id) REFERENCES skills(skill_id)
);

CREATE TABLE jobs (
  job_id NUMBER PRIMARY KEY,
  client_id NUMBER NOT NULL,
  title VARCHAR2(100) NOT NULL,
  description VARCHAR2(1000),
  budget NUMBER(10,2) CHECK (budget > 0),
  deadline DATE,
  status VARCHAR2(20) DEFAULT 'OPEN',
  created_at DATE DEFAULT SYSDATE,
  CONSTRAINT chk_deadline CHECK (deadline > TRUNC(SYSDATE)),
  FOREIGN KEY (client_id) REFERENCES users(user_id)
);

CREATE TABLE job_skills (
  job_id NUMBER,
  skill_id NUMBER,
  PRIMARY KEY (job_id, skill_id),
  FOREIGN KEY (job_id) REFERENCES jobs(job_id),
  FOREIGN KEY (skill_id) REFERENCES skills(skill_id)
);

CREATE TABLE proposals (
  proposal_id NUMBER PRIMARY KEY,
  job_id NUMBER NOT NULL,
  freelancer_id NUMBER NOT NULL,
  bid_amount NUMBER(10,2),
  cover_letter VARCHAR2(1000),
  submitted_at DATE DEFAULT SYSDATE,
  FOREIGN KEY (job_id) REFERENCES jobs(job_id),
  FOREIGN KEY (freelancer_id) REFERENCES freelancers(freelancer_id)
);

CREATE TABLE contracts (
  contract_id NUMBER PRIMARY KEY,
  job_id NUMBER NOT NULL,
  freelancer_id NUMBER NOT NULL,
  start_date DATE,
  end_date DATE,
  status VARCHAR2(20),
  FOREIGN KEY (job_id) REFERENCES jobs(job_id),
  FOREIGN KEY (freelancer_id) REFERENCES freelancers(freelancer_id)
);

CREATE TABLE ratings (
  rating_id NUMBER PRIMARY KEY,
  contract_id NUMBER NOT NULL,
  score NUMBER CHECK (score BETWEEN 1 AND 5),
  comment VARCHAR2(500),
  FOREIGN KEY (contract_id) REFERENCES contracts(contract_id)
);

-- ===========================
-- 3. TRIGGERS (PK autofill)
-- ===========================

CREATE OR REPLACE TRIGGER trg_users_pk
BEFORE INSERT ON users
FOR EACH ROW
BEGIN
  IF :NEW.user_id IS NULL THEN
    SELECT seq_users.NEXTVAL INTO :NEW.user_id FROM dual;
  END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_freelancers_pk
BEFORE INSERT ON freelancers
FOR EACH ROW
BEGIN
  IF :NEW.freelancer_id IS NULL THEN
    SELECT seq_freelancers.NEXTVAL INTO :NEW.freelancer_id FROM dual;
  END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_skills_pk
BEFORE INSERT ON skills
FOR EACH ROW
BEGIN
  IF :NEW.skill_id IS NULL THEN
    SELECT seq_skills.NEXTVAL INTO :NEW.skill_id FROM dual;
  END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_jobs_pk
BEFORE INSERT ON jobs
FOR EACH ROW
BEGIN
  IF :NEW.job_id IS NULL THEN
    SELECT seq_jobs.NEXTVAL INTO :NEW.job_id FROM dual;
  END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_proposals_pk
BEFORE INSERT ON proposals
FOR EACH ROW
BEGIN
  IF :NEW.proposal_id IS NULL THEN
    SELECT seq_proposals.NEXTVAL INTO :NEW.proposal_id FROM dual;
  END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_contracts_pk
BEFORE INSERT ON contracts
FOR EACH ROW
BEGIN
  IF :NEW.contract_id IS NULL THEN
    SELECT seq_contracts.NEXTVAL INTO :NEW.contract_id FROM dual;
  END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_ratings_pk
BEFORE INSERT ON ratings
FOR EACH ROW
BEGIN
  IF :NEW.rating_id IS NULL THEN
    SELECT seq_ratings.NEXTVAL INTO :NEW.rating_id FROM dual;
  END IF;
END;
/

-- ===========================
-- 4. PACKAGE SPECIFICATION
-- ===========================

CREATE OR REPLACE PACKAGE pkg_matching AS
  FUNCTION compute_match_score(
    p_job_id NUMBER,
    p_freelancer_id NUMBER,
    p_bid_amount NUMBER
  ) RETURN NUMBER;

  PROCEDURE find_top_matches(
    p_job_id NUMBER,
    p_limit NUMBER
  );
END pkg_matching;
/

-- ===========================
-- 5. PACKAGE BODY
-- ===========================

CREATE OR REPLACE PACKAGE BODY pkg_matching AS

  FUNCTION compute_match_score(p_job_id NUMBER, p_freelancer_id NUMBER, p_bid_amount NUMBER)
  RETURN NUMBER IS
    v_job_skill_count NUMBER := 0;
    v_matching_skills NUMBER := 0;
    v_skill_ratio NUMBER := 0;
    v_avg_rating NUMBER := 3;
    v_budget NUMBER := 1;
    v_bid NUMBER := NVL(p_bid_amount, 1);
    v_bid_factor NUMBER := 1;
    v_score NUMBER := 0;
  BEGIN
    SELECT COUNT(*) INTO v_job_skill_count FROM job_skills WHERE job_id = p_job_id;

    SELECT COUNT(*)
    INTO v_matching_skills
    FROM job_skills js
    JOIN freelancer_skills fs ON fs.skill_id = js.skill_id
    WHERE js.job_id = p_job_id AND fs.freelancer_id = p_freelancer_id;

    IF v_job_skill_count > 0 THEN
      v_skill_ratio := v_matching_skills / v_job_skill_count;
    END IF;

    BEGIN
      SELECT NVL(AVG(r.score), 3)
      INTO v_avg_rating
      FROM ratings r
      JOIN contracts c ON c.contract_id = r.contract_id
      WHERE c.freelancer_id = p_freelancer_id;
    END;

    BEGIN
      SELECT NVL(budget,1)
      INTO v_budget
      FROM jobs
      WHERE job_id = p_job_id;
    END;

    IF v_bid <= 0 THEN v_bid := 1; END IF;

    v_bid_factor := LEAST(2, GREATEST(0.5, (v_budget / v_bid)));

    v_score := (v_skill_ratio * 50) +
               ((v_avg_rating / 5) * 30) +
               ((v_bid_factor / 2) * 20);

    RETURN ROUND(v_score,2);
  END compute_match_score;


  PROCEDURE find_top_matches(p_job_id NUMBER, p_limit NUMBER) IS
    CURSOR c_freelancers IS
      SELECT f.freelancer_id, u.full_name
      FROM freelancers f
      JOIN users u ON u.user_id = f.user_id;

    TYPE t_rec IS RECORD (freelancer_id NUMBER, full_name VARCHAR2(200), score NUMBER);
    TYPE t_arr IS TABLE OF t_rec INDEX BY PLS_INTEGER;

    v_results t_arr;
    idx NUMBER := 0;
    v_score NUMBER;
    v_bid NUMBER;
  BEGIN
    DBMS_OUTPUT.PUT_LINE('Top matches for job ' || p_job_id);

    FOR r IN c_freelancers LOOP
      SELECT NVL(AVG(bid_amount), NULL)
      INTO v_bid
      FROM proposals
      WHERE job_id = p_job_id;

      v_score := compute_match_score(p_job_id, r.freelancer_id, v_bid);

      idx := idx + 1;
      v_results(idx).freelancer_id := r.freelancer_id;
      v_results(idx).full_name := r.full_name;
      v_results(idx).score := v_score;
    END LOOP;

    FOR i IN 1..idx-1 LOOP
      FOR j IN i+1..idx LOOP
        IF v_results(i).score < v_results(j).score THEN
          DECLARE tmp t_rec;
          BEGIN
            tmp := v_results(i);
            v_results(i) := v_results(j);
            v_results(j) := tmp;
          END;
        END IF;
      END LOOP;
    END LOOP;

    FOR i IN 1..LEAST(idx, p_limit) LOOP
      DBMS_OUTPUT.PUT_LINE(
        'Rank ' || i ||
        ': Freelancer=' || v_results(i).freelancer_id ||
        ' | ' || v_results(i).full_name ||
        ' | Score=' || v_results(i).score
      );
    END LOOP;

  END find_top_matches;

END pkg_matching;
/

-- ===========================
-- 6. TEST SCRIPT
-- ===========================

SET SERVEROUTPUT ON;

BEGIN
  pkg_matching.find_top_matches(1, 5);
END;
/
