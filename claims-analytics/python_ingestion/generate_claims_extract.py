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

# ---------------------------------------------------------
# 1. Generate Customers (customer grain)
# ---------------------------------------------------------
def generate_customers(n=2000):
    customers = []

    for i in range(n):
        customer_id = f"CUST-{300000 + i}"
        customers.append({
            "customer_id": customer_id,
            "customer_name": f"Customer {i}",
            "customer_address": f"{random.randint(100, 9999)} Main St",
            "customer_city": random.choice(["CityA", "CityB", "CityC", "CityD"]),
            "customer_state": random.choice(STATES),
            "customer_postal": f"{random.randint(90000, 99999)}",
            "customer_risk_score": round(random.uniform(0.0, 1.0) * 100, 2)
        })

    return customers

# ---------------------------------------------------------
# 2. Generate Policies (policy grain)
# ---------------------------------------------------------
def generate_policies(customers):
    policies = []

    for c in customers:
        policy_id = f"POL-{200000 + random.randint(0, 5000)}"
        effective = random_date()
        expiration = effective + timedelta(days=365)

        policies.append({
            "policy_id": policy_id,
            "customer_id": c["customer_id"],
            "policy_effective_date": effective,
            "policy_expiration_date": expiration,
            "policy_product_type": random.choice(TYPES),
            "policy_state": c["customer_state"]
        })

    return policies

# ---------------------------------------------------------
# 3. Generate Claims (claim grain)
# ---------------------------------------------------------
def generate_claims(customers, policies, n=5000):
    claims = []

    for i in range(n):
        policy = random.choice(policies)
        customer = next(c for c in customers if c["customer_id"] == policy["customer_id"])

        loss_date = random_date()
        report_date = loss_date + timedelta(days=random.randint(0, 5))
        close_date = report_date + timedelta(days=random.randint(5, 90)) if random.random() < 0.7 else None

        adjuster_id = f"ADJ-{400000 + random.randint(0, 500)}"

        claims.append({
            "claim_id": f"CLM-{100000 + i}",
            "policy_id": policy["policy_id"],
            "customer_id": customer["customer_id"],
            "adjuster_id": adjuster_id,
            "loss_date": loss_date.isoformat(),
            "report_date": report_date.isoformat(),
            "close_date": close_date.isoformat() if close_date else "",
            "claim_status": "CLOSED" if close_date else random.choice(STATUSES),
            "claim_type": random.choice(TYPES),
            "severity": random.choice(SEVERITIES),

            # Policy attributes
            "policy_effective_date": policy["policy_effective_date"].isoformat(),
            "policy_expiration_date": policy["policy_expiration_date"].isoformat(),
            "policy_product_type": policy["policy_product_type"],
            "policy_state": policy["policy_state"],

            # Customer attributes (stable!)
            "customer_name": customer["customer_name"],
            "customer_address": customer["customer_address"],
            "customer_city": customer["customer_city"],
            "customer_state": customer["customer_state"],
            "customer_postal": customer["customer_postal"],
            "customer_risk_score": customer["customer_risk_score"],

            # Adjuster attributes
            "adjuster_name": f"Adjuster {adjuster_id[-3:]}",
            "adjuster_region": random.choice(REGIONS),
            "adjuster_experience_years": round(random.uniform(1, 20), 1),

            # Payments
            "payment_count": random.randint(0, 5),
            "total_paid_amount": round(random.uniform(200, 5000), 2),
        })

    return claims

# ---------------------------------------------------------
# 4. Write CSV
# ---------------------------------------------------------
def main(n_rows=5000):
    customers = generate_customers(2000)
    policies = generate_policies(customers)
    claims = generate_claims(customers, policies, n_rows)

    fieldnames = list(claims[0].keys())

    with open(OUTPUT_FILE, "w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(claims)

    print(f"Wrote {n_rows} rows to {OUTPUT_FILE}")

if __name__ == "__main__":
    main()