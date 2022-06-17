# Python wrapper for terraform

Python wrapper for terraform.

## Running

- Copy file to Azure VM

```bash
    scp -i [KEY_FILE] main.py [USER]@[VM_NAME]:[PATH_TO_COPY_TO]
    scp -i [KEY_FILE] requirements.txt [USER]@[VM_NAME]:[PATH_TO_COPY_TO]
```

- Get Dependencies

```bash
    pip3 install -r requirements.txt
```

- Execute the script

```bash
    python3 main.py -o [TERRAFORM_OPERATION]
```
