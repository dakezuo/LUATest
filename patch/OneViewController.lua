waxClass{'OneViewController', UIViewController }

 

function init(self)

        self.super:init()

 

    self.input =UITextView:initWithFrame(CGRect(20, 20, 280, 114))

 

    self.output =UITextView:initWithFrame(CGRect(20, 184, 280, 225))

 

    local evalButton = UIButton:buttonWithType(UIButtonTypeRoundedRect)

   evalButton:setTitle_forState('Evaluate', UIControlStateNormal)

    evalButton:setFrame(CGRect(200,142, 100, 32))

   evalButton:addTarget_action_forControlEvents(self, 'eval:',

                           UIControlEventTouchUpInside)

   self.evalButton = evalButton

   

   self:view():addSubview(self.input)

    self:view():addSubview(self.output)

   self:view():addSubview(self.evalButton)

   

    return self

end

 

function eval(self, sender)

   self.input:resignFirstResponder()

 

    local code,errmsg = loadstring(self.input:text()) 

    if not code then

        self.output:setText(errmsg)

        return

    end

   

    local success,result = pcall(code)

    print('resultis ' .. tostring(result))

    if not success then

       self.output:setText('Error: ' .. tostring(result))

    else

        self.output:setText(tostring(result))

    end

   

end
