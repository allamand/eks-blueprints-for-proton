import subprocess
import sys
import json

def run_command(cmd):
    cmd_str = " ".join(cmd)
    print(f"Command: {cmd_str}")
    subprocess.run(cmd, check=True)

def list_entities_for_policy(policy_arn):
    cmd = ["aws", "iam", "list-entities-for-policy", "--policy-arn", policy_arn]
    output = subprocess.check_output(cmd)
    entities = json.loads(output)
    return entities

def detach_policy_from_entity(policy_arn, entity_name, entity_type):
    cmd = ["aws", "iam", "detach-role-policy", "--role-name", entity_name, "--policy-arn", policy_arn]
    run_command(cmd)

def delete_policy(policy_arn):
    cmd = ["aws", "iam", "delete-policy", "--policy-arn", policy_arn]
    run_command(cmd)

def delete_iam_policy(policy_name):
    cmd = ["aws", "iam", "list-policies", "--query", "Policies[?PolicyName=='{}'].Arn".format(policy_name), "--output", "text"]
    output = subprocess.check_output(cmd)
    policy_arn = output.decode("utf-8").strip()
    if not policy_arn:
        print(f"Policy '{policy_name}' not found.")
        return

    print(f"Checking if policy '{policy_name}' is attached to any entities...")
    entities = list_entities_for_policy(policy_arn)
    if entities:
        attached_entities = any(entity_list for entity_list in entities.values() if entity_list)
        if attached_entities:
            print(f"Policy '{policy_name}' is attached to the following entities:")
            for entity_type, entity_list in entities.items():
                if entity_list:
                    for entity in entity_list:
                        entity_name = entity.get("RoleName")
                        if entity_name:
                            print(f" - {entity_name} ({entity_type})")
                            detach_policy_from_entity(policy_arn, entity_name, entity_type)
            print(f"Policy '{policy_name}' detached from all entities.")
        else:
            print(f"No entities found attached to policy '{policy_name}'.")

    entities = list_entities_for_policy(policy_arn)
    if entities:
        attached_entities = any(entity_list for entity_list in entities.values() if entity_list)
        if attached_entities:
            print(f"Policy '{policy_name}' is still attached to the following entities:")
            for entity_type, entity_list in entities.items():
                if entity_list:
                    for entity in entity_list:
                        entity_name = entity.get("RoleName")
                        if entity_name:
                            print(f" - {entity_name} ({entity_type})")
            print("Please manually detach the policy from these entities before deleting.")
        else:
            print(f"No entities found attached to policy '{policy_name}'.")
            print(f"Deleting policy '{policy_name}'...")
            delete_policy(policy_arn)
            print(f"Policy '{policy_name}' deleted successfully.")
    else:
        print(f"Deleting policy '{policy_name}'...")
        delete_policy(policy_arn)
        print(f"Policy '{policy_name}' deleted successfully.")

# Usage: python script.py POLICY_NAME
policy_name = sys.argv[1]  # Get policy name from command-line argument
delete_iam_policy(policy_name)
