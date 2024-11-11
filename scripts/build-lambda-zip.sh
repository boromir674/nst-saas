#!/usr/bin/env sh

set -e

# Default values for optional parameters
HANDLER_FILE="lambda_function.py"

# Help message
show_help() {
    echo "Usage: $0 -r root_directory -p python_executable [-z zip_file_name] [-h handler_file]"
    echo ""
    echo "Options:"
    echo "  -r    Root directory of the project (required)"
    echo "  -p    Python executable (full or partial path, e.g., python3.11 or /usr/bin/python3.11) (required)"
    echo "  -z    Name of the ZIP file to create (default: <root_directory>.zip)"
    echo "  -h    Name of the handler file (default: lambda_function.py)"
    echo "  --help, -h    Show this help message"
}

# Parse CLI arguments
while getopts r:p:z:h: flag
do
    case "${flag}" in
        r) ROOT_DIR=${OPTARG};;
        p) PYTHON_EXEC=${OPTARG};;
        z) ZIP_FILE_NAME=${OPTARG};;
        h) HANDLER_FILE=${OPTARG};;
        *) show_help
           exit 1;;
    esac
done

# Check for required arguments
if [ -z "$ROOT_DIR" ] || [ -z "$PYTHON_EXEC" ]; then
    show_help
    exit 1
fi

# Set default ZIP file name if not provided
if [ -z "$ZIP_FILE_NAME" ]; then
    # strip possible trailing / from the root directory
    ZIP_FILE_NAME=$(basename $ROOT_DIR).zip
fi

cd $ROOT_DIR

# Create and activate a virtual environment using poetry
poetry env use $PYTHON_EXEC


# make sure poetry lock would not change the poetry.lock file
poetry lock
# check if the poetry.lock file is changed using git
if git diff --exit-code poetry.lock; then
    echo "poetry.lock file is not changed"
else
    echo "poetry.lock file is changed"
    echo "Please run poetry lock and commit the changes, before running this script"
    exit 1
fi


# Export requirements.txt
poetry export -f requirements.txt --output requirements.txt

# Create a virtual environment and install dependencies
$PYTHON_EXEC -m virtualenv env
. ./env/bin/activate
pip install -r requirements.txt

# Locate the directory where pip installed the dependencies
SITE_PACKAGES_DIR=$(python -c "import site; print(site.getsitepackages()[0])")

# Deactivate the virtual environment
deactivate

# Create a ZIP file with the installed dependencies
cd $SITE_PACKAGES_DIR
zip -r ../../../../$ZIP_FILE_NAME . -x '**/__pycache__/*' -x '__pycache__/*' -x '__pycache__/'

# Add the handler file to the ZIP package
cd ../../../../
zip $ZIP_FILE_NAME $HANDLER_FILE -x '__pycache__/'

echo "Deployment package $ZIP_FILE_NAME created successfully!"
echo
echo ":)"

# echo "Clean Up"
# rm -rf env

echo "Next steps:"
echo " 1. Upload the ZIP file to AWS Lambda"
