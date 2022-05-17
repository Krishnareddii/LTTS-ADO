#!/bin/python

import subprocess
import os
import sys
import json
from icecream import ic
import argparse
import shutil

# Global vars
TERRAFORM_EXECUTABLE = shutil.which("terraform")
if TERRAFORM_EXECUTABLE is None:
    TERRAFORM_EXECUTABLE = "C:\\bin\\terraform.exe"
TERRAFORM_SCRIPT_PATH = "C:\\Workspace\\TnS\\Krishna_Reddy\\terraform"

class Terraform:
    def __init__(self) -> None:
        os.environ["TF_IN_AUTOMATION"] = "1"
        self.command = {
            "version": "--version -json",
            "init": "init -input=false",
            "plan": "plan -input=false -compact-warnings -out=plan.out",
            "apply": "apply --auto-approve -input=false plan.out",
            "destroy": "destroy --auto-approve",
        }

    def get_operation(self):
        parser = argparse.ArgumentParser(description="Operation to perform")
        parser.add_argument("-o", "--operation", help="Operation to perform")
        args = parser.parse_args()
        if len(sys.argv) == 1:
            parser.print_help(sys.stderr)
            sys.exit(1)
        if args:
            OPERATION = args.operation
        return OPERATION

    def execute(self, command):
        process = subprocess.Popen(
            command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT
        )
        output = process.communicate()[0].decode("utf-8")
        exitCode = process.returncode
        return exitCode, output

    def info(self):
        command = TERRAFORM_EXECUTABLE + " " + self.command["version"]
        print(command)
        exitCode, output = self.execute(command)
        if exitCode == 0:
            TERRAFORM_VERSION = json.loads(output)["terraform_version"]
            ic(TERRAFORM_EXECUTABLE, TERRAFORM_VERSION, TERRAFORM_SCRIPT_PATH)
        else:
            ic("Terraform executable not found")

    def fmt(self):
        command = TERRAFORM_EXECUTABLE + " " + "fmt -recursive"
        exitCode, output = self.execute(command)
        if exitCode == 0:
            ic("Terraform fmt successful")
            print(output)
        else:
            ic("Terraform fmt failed")
            print(output)
            sys.exit(0)

    def init(self):
        self.fmt()
        command = TERRAFORM_EXECUTABLE + " " + self.command["init"]
        exitCode, output = self.execute(command)
        if exitCode == 0:
            ic("Terraform init successful")
            print(output)
        else:
            ic("Terraform init failed")
            print(output)

    def plan(self):
        self.init()
        command = TERRAFORM_EXECUTABLE + " " + self.command["plan"]
        exitCode, output = self.execute(command)
        if exitCode == 0:
            ic("Terraform plan successful")
            print(output)
        else:
            ic("Terraform plan failed")
            print(output)
            sys.exit(0)

    def apply(self):
        self.plan()
        command = TERRAFORM_EXECUTABLE + " " + self.command["apply"]
        exitCode, output = self.execute(command)
        if exitCode == 0:
            ic("Terraform apply successful")
            print(output)
        else:
            ic("Terraform apply failed")
            print(output)
            sys.exit(0)

    def destroy(self):
        command = TERRAFORM_EXECUTABLE + " " + "plan -destroy"
        exitCode, output = self.execute(command)
        if exitCode == 0:
            ic("Following resources will be destroyed:")
            print(output)
            command = TERRAFORM_EXECUTABLE + " " + self.command["destroy"]
            exitCode, output = self.execute(command)
            if exitCode == 0:
                ic("Terraform destroy successful")
                print(output)
            else:
                ic("Terraform destroy failed")
                print(output)
                sys.exit(0)
        else:
            ic("Destroy plan failed")
            print(output)
            sys.exit(0)


# Main
def main():
    os.chdir(TERRAFORM_SCRIPT_PATH)
    tf = Terraform()
    OPERATION = tf.get_operation()
    tf.info()
    switcher = {
        "fmt": tf.fmt,
        "init": tf.init,
        "plan": tf.plan,
        "apply": tf.apply,
        "destroy": tf.destroy,
    }
    switcher.get(OPERATION, lambda: "Incorrect Input")()

if __name__ == "__main__":
    main()
