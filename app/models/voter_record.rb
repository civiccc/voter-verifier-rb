# PORO wrapping elasticsearch results
class VoterRecord
  def to_thrift
    raise NotImplementedError
  end
end
