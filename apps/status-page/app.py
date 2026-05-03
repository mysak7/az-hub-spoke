import base64
import json
import os

from flask import Flask, render_template, request

app = Flask(__name__)

APPS = [
    {
        "key": "hr",
        "name": "HR Portal",
        "description": "Human Resources management and employee records",
        "url_env": "APP_HR_URL",
        "group_env": "GROUP_HR_ID",
    },
    {
        "key": "finance",
        "name": "Finance Dashboard",
        "description": "Financial reporting, budgets and analytics",
        "url_env": "APP_FINANCE_URL",
        "group_env": "GROUP_FINANCE_ID",
    },
    {
        "key": "admin",
        "name": "Admin Portal",
        "description": "Platform administration and configuration",
        "url_env": "APP_ADMIN_URL",
        "group_env": "GROUP_ADMINS_ID",
    },
]


def parse_principal(header: str):
    try:
        padding = (4 - len(header) % 4) % 4
        raw = base64.b64decode(header + "=" * padding)
        principal = json.loads(raw)
        claims = principal.get("claims", [])
        name = next((c["val"] for c in claims if c["typ"] == "name"), "")
        email = next(
            (c["val"] for c in claims if c["typ"] in ("preferred_username", "upn")),
            "",
        )
        groups = {c["val"] for c in claims if c["typ"] == "groups"}
        return {"name": name or email or "User", "email": email, "groups": groups}
    except Exception:
        return None


@app.route("/")
def index():
    header = request.headers.get("X-MS-CLIENT-PRINCIPAL", "")
    user = parse_principal(header) if header else None

    app_statuses = []
    for cfg in APPS:
        group_id = os.environ.get(cfg["group_env"], "")
        url = os.environ.get(cfg["url_env"], "#")
        has_access = bool(group_id) and bool(user) and group_id in user["groups"]
        app_statuses.append(
            {
                "key": cfg["key"],
                "name": cfg["name"],
                "description": cfg["description"],
                "url": url,
                "has_access": has_access,
            }
        )

    return render_template("index.html", user=user, apps=app_statuses)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8000, debug=False)
