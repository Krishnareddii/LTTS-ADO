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
    sys.exit("terraform not found")


class Terraform:
    def __init__(self = None):
        """
        Class init function to initialize terraform automation and set commands
        """
        os.environ["TF_IN_AUTOMATION"] = "1"
        self.command = {
            "version": "--version -json",
            "init": "init -input=false",
            "plan": "plan -input=false -compact-warnings -out=plan.out",
            "apply": "apply --auto-approve -input=false plan.out",
            "destroy": "destroy --auto-approve",
        }

    def get_inputs(self):
        """
        Get terraform operation from command line argument
        """
        parser = argparse.ArgumentParser(description="Operation to perform")
        parser.add_argument("-o", "--operation", help="Operation to perform")
        parser.add_argument("-p", "--path", help="Path of terraform script")
        args = parser.parse_args()
        if len(sys.argv) == 1:
            parser.print_help(sys.stderr)
            sys.exit(1)
        if args:
            OPERATION = args.operation
            TERRAFORM_SCRIPT_PATH = args.path
        return OPERATION, TERRAFORM_SCRIPT_PATH

    def execute(self, command):
        """
        Run shell commands from python
        """
        process = subprocess.Popen(
            command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT
        )
        output = process.communicate()[0].decode("utf-8")
        exitCode = process.returncode
        return exitCode, output

    def info(self, TERRAFORM_SCRIPT_PATH):
        """
        Get terraform info
        """
        command = TERRAFORM_EXECUTABLE + " " + self.command["version"]
        print(command)
        exitCode, output = self.execute(command)
        if exitCode == 0:
            TERRAFORM_VERSION = json.loads(output)["terraform_version"]
            ic(TERRAFORM_EXECUTABLE, TERRAFORM_VERSION, TERRAFORM_SCRIPT_PATH)
        else:
            ic("Terraform executable not found")

    def fmt(self):
        """
        Run terraform fmt --recursive
        """
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
        """
        Run terraform init
        """
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
        """
        Run terraform plan
        """
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
        """
        Run terraform apply
        """
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
        """
        Run terraform destroy
        """
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
    # Create class object
    tf = Terraform()

    # Get operation to perform
    OPERATION, TERRAFORM_SCRIPT_PATH = tf.get_inputs()

    # cd to TERRAFORM_SCRIPT_PATH
    os.chdir(TERRAFORM_SCRIPT_PATH)

    # Print Info
    tf.info(TERRAFORM_SCRIPT_PATH)

    # Use switcher to perform operation
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
