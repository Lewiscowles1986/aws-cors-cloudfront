resource "aws_cloudfront_distribution" "example" {
  enabled = true
  origin {
    domain_name = "example.com"
    origin_id   = "example-origin"
    origin_path = ""

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_protocol_policy   = "https-only"
      origin_ssl_protocols     = ["TLSv1.2"]
      origin_keepalive_timeout = 5
      origin_read_timeout      = 30
    }
  }

  origin {
    domain_name = replace(
        replace(aws_apigatewayv2_stage.example_stage.invoke_url, "https://", ""),
        "/${aws_apigatewayv2_stage.example_stage.name}",
        ""
    )
    origin_id   = "jsonplaceholder-origin-api-stripped"
    origin_path = "/${aws_apigatewayv2_stage.example_stage.name}"

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_protocol_policy   = "https-only"
      origin_ssl_protocols     = ["TLSv1.2"]
      origin_keepalive_timeout = 5
      origin_read_timeout      = 30
    }
  }

  default_cache_behavior {
    target_origin_id       = "example-origin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      query_string = true
      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  custom_error_response {
    error_code            = 404
    response_code         = 404
    response_page_path    = "/404.html"
    error_caching_min_ttl = 300
  }

  ordered_cache_behavior {
    path_pattern           = "/api/user*"
    target_origin_id       = "jsonplaceholder-origin-api-stripped"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      query_string = true
      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
  }

  tags = {
    Name = "cloudfront-distribution-example"
  }
}

resource "aws_apigatewayv2_api" "example" {
  name          = "example-http-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "proxy_integration" {
  api_id = aws_apigatewayv2_api.example.id
  integration_type = "HTTP_PROXY"
  integration_uri  = "https://jsonplaceholder.typicode.com/{proxy}"
  integration_method = "ANY"
}

resource "aws_apigatewayv2_route" "proxy_route" {
  api_id = aws_apigatewayv2_api.example.id
  route_key = "ANY /api/{proxy+}"
  target = "integrations/${aws_apigatewayv2_integration.proxy_integration.id}"
}

resource "aws_apigatewayv2_stage" "example_stage" {
  api_id = aws_apigatewayv2_api.example.id
  name = "prod"
  auto_deploy = true
}
