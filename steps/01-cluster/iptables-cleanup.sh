echo "Flushing all the calico iptables chains in the nat table..."
iptables-save -t nat | grep -oP '(?<!^:)cali-[^ ]+' | while read line; do iptables -t nat -F $line; done

echo "Flushing all the calico iptables chains in the raw table..."
iptables-save -t raw | grep -oP '(?<!^:)cali-[^ ]+' | while read line; do iptables -t raw -F $line; done

echo "Flushing all the calico iptables chains in the mangle table..."
iptables-save -t mangle | grep -oP '(?<!^:)cali-[^ ]+' | while read line; do iptables -t mangle -F $line; done

echo "Flushing all the calico iptables chains in the filter table..."
iptables-save -t filter | grep -oP '(?<!^:)cali-[^ ]+' | while read line; do iptables -t filter -F $line; done

echo "Cleaning up calico rules from the nat table..."
iptables-save -t nat | grep -e '--comment "cali:' | cut -c 3- | sed 's/^ *//;s/ *$//' | xargs -l1 iptables -t nat -D

echo "Cleaning up calico rules from the raw table..."
iptables-save -t raw | grep -e '--comment "cali:' | cut -c 3- | sed 's/^ *//;s/ *$//' | xargs -l1 iptables -t raw -D

echo "Cleaning up calico rules from the mangle table..."
iptables-save -t mangle | grep -e '--comment "cali:' | cut -c 3- | sed 's/^ *//;s/ *$//' | xargs -l1 iptables -t mangle -D

echo "Cleaning up calico rules from the filter table..."
iptables-save -t filter | grep -e '--comment "cali:' | cut -c 3- | sed 's/^ *//;s/ *$//' | xargs -l1 iptables -t filter -D


iptables-save -t nat | grep -e ':cali-' | cut -c 2- | cut -d' ' -f1 | while read line; do iptables -t nat -X $line; done
iptables-save -t raw | grep -e ':cali-' | cut -c 2- | cut -d' ' -f1 | while read line; do iptables -t raw -X $line; done
iptables-save -t mangle | grep -e ':cali-' | cut -c 2- | cut -d' ' -f1 | while read line; do iptables -t mangle -X $line; done
iptables-save -t filter | grep -e ':cali-' | cut -c 2- | cut -d' ' -f1 | while read line; do iptables -t filter -X $line; done


#echo "Cleaning up remaining calico chain rules"
#iptables --list | grep -e "Chain cali" | cut -c 7- | rev | cut -c  15- | rev | while read line; do iptables -X $line; done


echo "Flushing all the KUBE iptables chains in the nat table..."
iptables-save -t nat | grep -oP '(?<!^:)KUBE-[^ ]+' | while read line; do iptables -t nat -F $line; done

echo "Flushing all the KUBE iptables chains in the raw table..."
iptables-save -t raw | grep -oP '(?<!^:)KUBE-[^ ]+' | while read line; do iptables -t raw -F $line; done

echo "Flushing all the KUBE iptables chains in the mangle table..."
iptables-save -t mangle | grep -oP '(?<!^:)KUBE-[^ ]+' | while read line; do iptables -t mangle -F $line; done

echo "Flushing all the KUBE iptables chains in the filter table..."
iptables-save -t filter | grep -oP '(?<!^:)KUBE-[^ ]+' | while read line; do iptables -t filter -F $line; done

echo "Cleaning up kubernetes rules from the nat table..."
iptables-save -t nat | grep -e '--comment "kubernetes' | cut -c 3- | sed 's/^ *//;s/ *$//' | xargs -l1 iptables -t nat -D

echo "Cleaning up kubernetes rules from the raw table..."
iptables-save -t raw | grep -e '--comment "kubernetes' | cut -c 3- | sed 's/^ *//;s/ *$//' | xargs -l1 iptables -t raw -D

echo "Cleaning up kubernetes rules from the mangle table..."
iptables-save -t mangle | grep -e '--comment "kubernetes' | cut -c 3- | sed 's/^ *//;s/ *$//' | xargs -l1 iptables -t mangle -D

echo "Cleaning up kubernetes rules from the filter table..."
iptables-save -t filter | grep -e '--comment "kubernetes' | cut -c 3- | sed 's/^ *//;s/ *$//' | xargs -l1 iptables -t filter -D

iptables-save -t nat | grep -e ':KUBE-' | cut -c 2- | cut -d' ' -f1 | while read line; do iptables -t nat -X $line; done
iptables-save -t raw | grep -e ':KUBE-' | cut -c 2- | cut -d' ' -f1 | while read line; do iptables -t raw -X $line; done
iptables-save -t mangle | grep -e ':KUBE-' | cut -c 2- | cut -d' ' -f1 | while read line; do iptables -t mangle -X $line; done
iptables-save -t filter | grep -e ':KUBE-' | cut -c 2- | cut -d' ' -f1 | while read line; do iptables -t filter -X $line; done