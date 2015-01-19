describe StatusCreator do
  subject { described_class }

  describe '.create' do
    it 'creates a new status' do
      status_data = {
        "lat" => '42.969624',
        "long" => '-85.664793',
        "body" => 'Going to Founders!',
        "duration" => '1200',
        "image_url" => "http://something.com"
      }

      user_id = 123

      status = subject.create(status_data, user_id)
      status.should_not be_nil
      status.lat.should == '42.969624'
      status.long.should == '-85.664793'
      status.user_id.should == 123
    end

    it 'failes to create new status if lat is empty' do
      status_data = {
        "lat" => '',
        "long" => '-85.664793',
        "body" => 'Going to Founders!',
        "duration" => '1200',
        "image_url" => "http://something.com"
      }

      expect {subject.create(status_data, 123)}.to raise_error
    end

    it 'failes to create new status if long is empty' do
      status_data = {
        "lat" => '42.969624',
        "long" => '',
        "body" => 'Going to Founders!',
        "duration" => '1200',
        "image_url" => "http://something.com"
      }

      expect {subject.create(status_data, 123)}.to raise_error
    end

    it 'failes to create new status if status body is empty' do
      status_data = {
        "lat" => '223',
        "long" => '-85.664793',
        "body" => '',
        "duration" => '1200',
        "image_url" => "http://something.com"
      }

      expect {subject.create(status_data, 123)}.to raise_error
    end


    it 'failes to create new status if status body is empty' do
      status_data = {
        "lat" => '223',
        "long" => '-85.664793',
        "body" => 'something',
        "duration" => '',
        "image_url" => "http://something.com"
      }

      expect {subject.create(status_data, 123)}.to raise_error
    end
  end
end