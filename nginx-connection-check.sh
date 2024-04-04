#!/bin/bash

# Check login status to Azure
az login --identity

# Set the cluster name, resource group name, and node pool name.
CLUSTER_NAME=CAC_cluster
RESOURCE_GROUP=netbako
NODEPOOL_NAME=userpool

# Get credentials for the AKS cluster.
az aks get-credentials --name $CLUSTER_NAME --resource-group $RESOURCE_GROUP --overwrite-existing

# Start infinite loop
while true; do
  # Get the current node pool status of the AKS cluster.
  node_pool=$(az aks nodepool list --cluster-name $CLUSTER_NAME --resource-group $RESOURCE_GROUP -o json)
  echo "Current node pool status in the AKS cluster:"

  # Check the current node count in the node pool.
  current_node_count=$(echo "$node_pool" | jq -r ".[] | select(.name==\"$NODEPOOL_NAME\") | .count")
  echo "Current node count: $current_node_count"

  # Check the status of all pods running on all nodes
  nodes=$(kubectl get nodes -o name | grep 'userpool')
  
  # Variable to check if there are pods with more than 6 active connections
  should_scale_up_num=0
  # Variable to check if there are pods with 0 active connections
  should_scale_down_num=0
  
  for node in $nodes; do
    echo "Checking pods running on node $node:"

    # List pods per node
    pods=$(kubectl get pods --all-namespaces --field-selector spec.nodeName=${node#node/} -o json)

    while read pod_name pod_ip pod_namespace; do
      if [[ "$pod_name" == *"nginx"* ]]; then
        # Add desired actions here. For example: echo "$pod_name"
        echo "Pod name: $pod_name, Pod IP: $pod_ip"

        # Get active connections count from Nginx status page
        active_connections=$(kubectl exec $pod_name -- curl -s http://$pod_ip/basic_status | grep "Active connections" | awk '{print $3}')
        echo "Active connections for pod $pod_name: $active_connections"

        # If active connections are 6 or more, increment increase value by 1
        if [ "$active_connections" -ge 6 ]; then
          echo "Active connections are 6 or more. Adding node."
          ((should_scale_up_num++))
        # If active connections are 0, increment decrease value by 1
        elif [ "$active_connections" -eq 1 ]; then
          echo "Active connections are 1. Removing node."
          ((should_scale_down_num++))
        fi
	  else
	    
      fi
    done < <(echo "$pods" | jq -r '.items[] | "\(.metadata.name) \(.status.podIP) \(.metadata.namespace)"')
  done

  net_scale=$((should_scale_up_num - should_scale_down_num))
  echo "Net scale: $net_scale"
  new_node_count=$((current_node_count + net_scale))
  echo "New node count: $new_node_count"
  if [ $net_scale -ge 1 ]; then
      az aks nodepool scale --cluster-name $CLUSTER_NAME --name $NODEPOOL_NAME --resource-group $RESOURCE_GROUP --node-count $new_node_count
  fi
  
  # Wait for 5 minutes 300 seconds
  sleep 300
done