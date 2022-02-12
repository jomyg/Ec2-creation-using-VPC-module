output "bastion_public_ip" {
    
   value = aws_instance.bastion.public_ip    
}

output "webserver_public_ip" {
   value = aws_instance.webserver.public_ip  
    
}

output "webserver_private_ip" {
   value = aws_instance.webserver.private_ip  
    
}

output "database_private_ip" {
  value = aws_instance.database.private_ip    
    
}
