import subprocess
import json
import sys

class CommandExecutionError(Exception):
    def __init__(self, cmd, error):
        self.cmd = cmd
        self.error = error
        super().__init__(f"Error executing command: {cmd}\n{error}")


def run_command(cmd):
    cmd_str = " ".join(cmd)
    print(f"Command: {cmd_str}")
    try:
        output = subprocess.check_output(cmd)
        return output.decode("utf-8").strip()
    except subprocess.CalledProcessError as e:
        raise CommandExecutionError(cmd, e.output.decode("utf-8"))


def list_attached_policies(role_name):
    cmd = ["aws", "iam", "list-attached-role-policies", "--role-name", role_name]
    try:
        output = run_command(cmd)
        policies = json.loads(output)["AttachedPolicies"]
        return [policy["PolicyArn"] for policy in policies]
    except CommandExecutionError as e:
        if "NoSuchEntity" in e.error:
            print(f"Role '{role_name}' not found.")
        else:
            print(f"Error listing attached policies for role '{role_name}': {e.error}")
        return []


def detach_policy(role_name, policy_arn):
    cmd = ["aws", "iam", "detach-role-policy", "--role-name", role_name, "--policy-arn", policy_arn]
    try:
        run_command(cmd)
    except CommandExecutionError as e:
        print(f"Error detaching policy '{policy_arn}' from role '{role_name}': {e.error}")


def delete_role(role_name):
    cmd = ["aws", "iam", "delete-role", "--role-name", role_name]
    try:
        run_command(cmd)
    except CommandExecutionError as e:
        print(f"Error deleting role '{role_name}': {e.error}")


def delete_role_with_policies(role_name):
    # Check if the role exists
    cmd = ["aws", "iam", "get-role", "--role-name", role_name]
    try:
        output = run_command(cmd)
        if "Role" not in output:
            print(f"Role '{role_name}' not found.")
            return
    except CommandExecutionError as e:
        print(f"Error checking role '{role_name}': {e.error}")
        return

    # Detach policies from the role
    attached_policies = list_attached_policies(role_name)
    for policy_arn in attached_policies:
        detach_policy(role_name, policy_arn)

    # Delete the role
    delete_role(role_name)


# Usage: python script.py ROLE_NAME
role_name = sys.argv[1]  # Get role name from command-line argument
delete_role_with_policies(role_name)
