module RestAdapter

  class PageResource < Resource
    include RestAdapter::Config::CyberCoach
    include RestAdapter::Behaviours::ActiveRecord

  end

  class UserPage < PageResource



  end

end