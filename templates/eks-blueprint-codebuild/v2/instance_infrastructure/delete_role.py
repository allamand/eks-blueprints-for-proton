import subprocess
import json
import sys

def list_attached_policies(role_name):
    cmd = ["aws", "iam", "list-attached-role-policies", "--role-name", role_name]
    try:
        output = subprocess.check_output(cmd)
        policies = json.loads(output)["AttachedPolicies"]
        return [policy["PolicyArn"] for policy in policies]
    except subprocess.CalledProcessError as e:
        if "NoSuchEntity" in e.output.decode("utf-8"):
            print(f"Role '{role_name}' not found.")
        else:
            print(f"Error listing attached policies for role '{role_name}': {e}")
        return []

def detach_policy(role_name, policy_arn):
    cmd = ["aws", "iam", "detach-role-policy", "--role-name", role_name, "--policy-arn", policy_arn]
    try:
        subprocess.run(cmd, check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error detaching policy '{policy_arn}' from role '{role_name}': {e}")

def delete_role(role_name):
    cmd = ["aws", "iam", "delete-role", "--role-name", role_name]
    try:
        subprocess.run(cmd, check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error deleting role '{role_name}': {e}")

def delete_role_with_policies(role_name):
    attached_policies = list_attached_policies(role_name)
    if not attached_policies:
        return

    for policy_arn in attached_policies:
        detach_policy(role_name, policy_arn)
    delete_role(role_name)

# Usage: python script.py ROLE_NAME
role_name = sys.argv[1]  # Get role name from command-line argument
delete_role_with_policies(role_name)
