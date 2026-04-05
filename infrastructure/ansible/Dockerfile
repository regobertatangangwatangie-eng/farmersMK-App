FROM python:3.12-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends openssh-client git && \
    rm -rf /var/lib/apt/lists/* && \
    pip install --no-cache-dir ansible && \
    mkdir -p /root/.ssh && chmod 700 /root/.ssh

# Copy ansible project with correct (non-world-writable) permissions
WORKDIR /ansible
COPY . /ansible/
RUN chmod 600 /ansible/ansible.cfg 2>/dev/null || true

ENTRYPOINT ["ansible-playbook"]
