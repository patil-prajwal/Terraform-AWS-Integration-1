provider "kubernetes" {
    config_context = "minikube"
}

resource "kubernetes_deployment" "wps" {
    metadata {
        name = "wordpress"
        labels = {
            app = "wordpress"
        }
    }
    spec {
        replicas = 2
        selector {
            match_labels = {
                app = "wordpress"
               
            }
        }
    template {
        metadata {
            labels = {
                app = "wordpress"

            }
        }
        spec {
            container {
                image = "wordpress"
                name  = "wordpress"
            }
        }
    }
  }
}

resource "kubernetes_service" "service" {
    metadata {
        name = "wordpress"
    }
    spec {
        selector = {
            app = "wordpress"

        }
        session_affinity = "ClientIP"
        port {
            node_port = 31000
            port = 80
            target_port = 80
        }
        type = "NodePort"
    }
}

provider "aws" {
    region = "ap-south-1"

}

resource "aws_db_instance" "mysql" {
    engine = "mysql"
    engine_version = "5.7.30"
    allocated_storage = 10
    storage_type = "gp2"
    instance_class = "db.t2.micro"     
    name = "mydb1"
    username = "prajwal"
    password = "password"
    port = 3306
    parameter_group_name = "default.mysql5.7"
    skip_final_snapshot= true
    publicly_accessible = true 
}

