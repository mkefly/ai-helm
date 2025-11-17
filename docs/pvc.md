# PVCs & Data Mounts

PVCs are environment-specific and created outside the chart.

## Example: Azure Blob NFS

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: shared-blob-pvc
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: azure-blob-nfs-premium
  resources:
    requests:
      storage: 100Gi
```

## Example: Azure Files

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: models-blob-pvc
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: azurefile-csi
  resources:
    requests:
      storage: 100Gi
```

### Mount in workloads

```yaml
volumeMounts:
  - name: blob-store
    mountPath: /mnt/blob
volumes:
  - name: blob-store
    persistentVolumeClaim:
      claimName: shared-blob-pvc
```
