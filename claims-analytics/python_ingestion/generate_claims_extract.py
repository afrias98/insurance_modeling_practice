import csv
import random
from datetime import datetime, timedelta
from pathlib import Path

OUTPUT_DIR = Path(__file__).resolve().parent / "data"
OUTPUT_DIR.mkdir(exist_ok=True)
OUTPUT_FILE = OUTPUT_DIR / "claims_extract.csv"

STATUSES = ["OPEN", "CLOSED", "PENDING_DOCS", "UNDER_REVIEW"]
TYPES = ["AUTO", "HOME", "LIFE", "UMBRELLA"]
SEVERITIES = ["LOW", "MEDIUM", "HIGH", "TOTAL_LOSS"]
STATES = ["CA", "NY", "TX", "FL", "WA"]
REGIONS = ["WEST", "EAST", "SOUTH", "MIDWEST"]

def random_date(start_days_ago=365, end_days_ago=0):
    days_ago = random.randint(end_days_ago, start_days_ago)
    return datetime.utcnow() - timedelta(days=days_ago)

def generate_row(i: int) -> dict:
    claim_id = f"CLM-{100000 + i}"
    policy_id = f"POL-{200000 + random.randint(0, 5000)}"
    customer_id = f"CUST-{300000 + random.randint(0, 5000)}"
    adjuster_id = f"ADJ-{400000 + random.randint(0, 500)}"

    loss_date = random_date()
    report_date = loss_date + timedelta(days=random.randint(0, 5))
    close_date = report_date + timedelta(days=random.randint(5, 90)) if random.random() < 0.7 else None

    claim_status = "CLOSED" if close_date else random.choice(STATUSES)
    claim_type = random.choice(TYPES)
    severity = random.choice(SEVERITIES)

    policy_effective_date = loss_date - timedelta(days=random.randint(0, 180))
    policy_expiration_date = policy_effective_date + timedelta(days=365)
    policy_product_type = claim_type
    policy_state = random.choice(STATES)

    customer_name = f"Customer {customer_id[-4:]}"
    customer_address = f"{random.randint(100, 9999)} Main St"
    customer_city = "City" + random.choice(["A", "B", "C", "D"])
    customer_state = policy_state
    customer_postal = f"{random.randint(90000, 99999)}"
    customer_risk_score = round(random.uniform(0.0, 1.0) * 100, 2)

    adjuster_name = f"Adjuster {adjuster_id[-3:]}"
    adjuster_region = random.choice(REGIONS)
    adjuster_experience_years = round(random.uniform(1, 20), 1)

    payment_count = random.randint(0, 5)
    total_paid_amount = round(payment_count * random.uniform(200, 5000), 2)

    return {
        "claim_id": claim_id,
        "policy_id": policy_id,
        "customer_id": customer_id,
        "adjuster_id": adjuster_id,
        "loss_date": loss_date.isoformat(),
        "report_date": report_date.isoformat(),
        "close_date": close_date.isoformat() if close_date else "",
        "claim_status": claim_status,
        "claim_type": claim_type,
        "severity": severity,
        "policy_effective_date": policy_effective_date.isoformat(),
        "policy_expiration_date": policy_expiration_date.isoformat(),
        "policy_product_type": policy_product_type,
        "policy_state": policy_state,
        "customer_name": customer_name,
        "customer_address": customer_address,
        "customer_city": customer_city,
        "customer_state": customer_state,
        "customer_postal": customer_postal,
        "customer_risk_score": customer_risk_score,
        "adjuster_name": adjuster_name,
        "adjuster_region": adjuster_region,
        "adjuster_experience_years": adjuster_experience_years,
        "payment_count": payment_count,
        "total_paid_amount": total_paid_amount,
    }

def main(n_rows: int = 5000):
    fieldnames = list(generate_row(0).keys())
    with open(OUTPUT_FILE, "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        for i in range(n_rows):
            writer.writerow(generate_row(i))
    print(f"Wrote {n_rows} rows to {OUTPUT_FILE}")

if __name__ == "__main__":
    main()
