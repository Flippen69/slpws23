
class AuthMiddleware
    def initialize(app)
        @app = app
    end

    def call(env)
        path = env["PATH_INFO"]
        p path
        user_id = env["rack.session"][":id"]
        p user_id

        if !path.start_with?("/showlogin") && !path.start_with?("/register") && env['REQUEST_METHOD'] != "POST" && !user_id
            response = Rack::Response.new
            response.redirect('/showlogin')
            response.finish
        else
            @app.call(env)
        end
    end
end

