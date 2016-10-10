# Raised when an operation is attempted on a resource
# that is not valid on the resources because of its
# current state
class InvalidState < StandardError
end
