### What is being deployed

![diagram](https://github.com/Emerson-Valentim/nginx-cache/assets/69153761/b46501fd-3e89-4ca2-bba4-1d61c392c739)

### What behavior is being tested

Sharing volumes locally is no big deal, but running it on cloud may be challenging. The current solution uses EFS, a highly available and durable NFS, to share storage between EC2 instances. The main idea is to enable NGINX to share cache through multiple instances and improve consistency when horizontal scaling is needed.