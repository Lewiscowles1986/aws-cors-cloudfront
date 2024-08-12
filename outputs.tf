output "url" {
    value = "https://${aws_cloudfront_distribution.example.domain_name}"
}

output "apigw_invoke_url" {
    value = aws_apigatewayv2_stage.example_stage.invoke_url
}

output "apigw_invoke_url_stripped" {
    value = replace(
        replace(aws_apigatewayv2_stage.example_stage.invoke_url, "https://", ""),
        "/${aws_apigatewayv2_stage.example_stage.name}",
        ""
    )
}