#!/bin/bash
# Create gng-backend-secret in OpenShift
# Run this script before deploying the application

set -e

NAMESPACE="griot-grits-aa488b"

echo "================================================================"
echo "  Creating Secret for Griot and Grits Backend"
echo "================================================================"
echo ""

# Check if logged into OpenShift
if ! oc whoami &>/dev/null; then
    echo "ERROR: Not logged into OpenShift. Please run 'oc login' first."
    exit 1
fi

# Check if namespace exists
if ! oc get namespace ${NAMESPACE} &>/dev/null; then
    echo "ERROR: Namespace ${NAMESPACE} does not exist."
    exit 1
fi

# Get MongoDB credentials from existing secret
echo "Getting MongoDB credentials from mongodb secret..."
MONGO_PASSWORD=$(oc get secret mongodb -n ${NAMESPACE} -o jsonpath='{.data.mongodb-root-password}' 2>/dev/null | base64 -d || echo "")

if [ -z "$MONGO_PASSWORD" ]; then
    echo "WARNING: Could not get MongoDB root password from mongodb secret"
    read -sp "Enter MongoDB root password: " MONGO_PASSWORD
    echo ""
fi

# Construct MongoDB URI
MONGO_USER="root"
MONGO_HOST="mongodb-0.${NAMESPACE}.svc.cluster.local:27017"
DB_URI="mongodb://${MONGO_USER}:${MONGO_PASSWORD}@${MONGO_HOST}/"

# Get MinIO credentials
echo ""
echo "Enter MinIO credentials:"
read -p "MinIO Access Key [minioadmin]: " MINIO_ACCESS_KEY
MINIO_ACCESS_KEY=${MINIO_ACCESS_KEY:-minioadmin}

read -sp "MinIO Secret Key [minioadmin]: " MINIO_SECRET_KEY
echo ""
MINIO_SECRET_KEY=${MINIO_SECRET_KEY:-minioadmin}

# Optional: Globus credentials
echo ""
read -p "Enable Globus? (y/N): " ENABLE_GLOBUS
if [[ "$ENABLE_GLOBUS" =~ ^[Yy]$ ]]; then
    read -p "Globus Client ID: " GLOBUS_CLIENT_ID
    read -sp "Globus Client Secret: " GLOBUS_CLIENT_SECRET
    echo ""
    read -p "Globus Endpoint ID: " GLOBUS_ENDPOINT_ID
else
    GLOBUS_CLIENT_ID=""
    GLOBUS_CLIENT_SECRET=""
    GLOBUS_ENDPOINT_ID=""
fi

# Delete existing secret if it exists
echo ""
if oc get secret gng-backend-secret -n ${NAMESPACE} &>/dev/null; then
    echo "Deleting existing gng-backend-secret..."
    oc delete secret gng-backend-secret -n ${NAMESPACE}
fi

# Create the secret
echo "Creating gng-backend-secret..."
oc create secret generic gng-backend-secret \
  --from-literal=DB_URI="${DB_URI}" \
  --from-literal=STORAGE_ACCESS_KEY="${MINIO_ACCESS_KEY}" \
  --from-literal=STORAGE_SECRET_KEY="${MINIO_SECRET_KEY}" \
  --from-literal=GLOBUS_CLIENT_ID="${GLOBUS_CLIENT_ID}" \
  --from-literal=GLOBUS_CLIENT_SECRET="${GLOBUS_CLIENT_SECRET}" \
  --from-literal=GLOBUS_ENDPOINT_ID="${GLOBUS_ENDPOINT_ID}" \
  --from-literal=PROCESSING_TRANSCRIPTION_API_URL="" \
  --from-literal=PROCESSING_CELERY_BROKER_URL="" \
  --from-literal=PROCESSING_CELERY_RESULT_BACKEND="" \
  -n ${NAMESPACE}

echo ""
echo "================================================================"
echo "  Secret created successfully!"
echo "================================================================"
echo ""
echo "Next steps:"
echo "  1. Verify secret: oc get secret gng-backend-secret -n ${NAMESPACE}"
echo "  2. Deploy application: kubectl apply -k applications/gng-backend/"
echo "  3. Or sync with ArgoCD if configured"
echo ""
