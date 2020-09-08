docker build  --tag=flaskapp:latest .
kubectl apply -f mysql.yaml
kubectl apply -f python-app.yaml