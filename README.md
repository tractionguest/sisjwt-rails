# Sisjwt::Rails

This gem allows you to easily integrate the [`sisjwt-ruby`](https://github.com/tractionguest/sisjwt-ruby) rubygem into your Rails controllers.

## Usage

To authenticate your controller with `Sisjwt`, you need only mixin the `Sisjwt::Rails::Verification` concern, and set the expected `sisjwt_iss` and `sisjwt_aud`. Ensure that you disable other authentication schemes.

Every endpoint in the controller with be authenticated by default, so you will need to explictitly disable `authenticate_sisjwt` on any that you want to be in the clear.

### Example controller

``` ruby
class IncomingFromSicController < ApplicationController
  include Sisjwt::Rails::Verification

  sisjwt_iss :sic
  sisjwt_aud :sie

  skip_before_action :authenticate_current_user
  skip_before_action :authenticate_sisjwt, only: :unauthenticated_endpoint

  def authenticated_endpoint
    # ...
  end

  def unauthenticated_endpoint
    # ...
  end
end
```
