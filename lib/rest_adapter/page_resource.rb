module RestAdapter

  class PageResource < Resource
    include RestAdapter::Config::CyberCoach
    include RestAdapter::ResourceOperations

  end

  class UserPage < PageResource

    set_re

  end

end