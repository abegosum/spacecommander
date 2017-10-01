#   Copyright 2017 Aaron M. Bond
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
# A mixin allowing the use of bytes_attr_accessor to create instances of the 
# Bytes numeric extension within a class.
module Byteable
  def bytes_attr_accessor *method_names
    attr_reader *method_names
    method_names.each do |method_name|
      define_method "#{method_name.to_s}=" do |bytes|
        coerced = case bytes
                  when Bytes
                    bytes
                  else
                    Bytes.new bytes
                  end
        instance_variable_set "@#{method_name}", coerced
      end
    end
  end

end
