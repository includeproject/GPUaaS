#!/usr/bin/python

import subprocess
import shlex

# Script for auto-generate the different services keys for Openstack


services = [
            "RABBIT_PASS",
            "KEYSTONE_DBPASS",
            "DEMO_PASS",
            "ADMIN_PASS",
            "GLANCE_DBPASS",
            "GLANCE_PASS",
            "NOVA_DBPASS",
            "NOVA_PASS",
            "DASH_DBPASS",
            "CINDER_DBPASS",
            "CINDER_PASS",
            "NEUTRON_DBPASS",
            "NEUTRON_PASS",
            "HEAT_DBPASS",
            "HEAT_PASS",
            "CEILOMETER_DBPASS",
            "CEILOMETER_PASS",
            "TROVE_DBPASS",
            "TROVE_PASS",
            "ADMIN_TOKEN",
            "METADATA_SECRET",
            ]


def generate(service):
    """
    This function will take a list of services and it will generate
    the hexadecimal keys and then it will write to a file named keys.
    """
    f = open("keys", "w")
    for x in service:       
        y = subprocess.check_output(shlex.split('openssl rand -hex 10'))
        f.write(x + ":" + y + "\n")    
    f.close()


generate(services)
        