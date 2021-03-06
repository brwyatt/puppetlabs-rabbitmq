require 'spec_helper'

describe 'rabbitmq::server' do

  let(:facts) {{ :osfamily => 'Debian', :lsbdistcodename => 'precise' }}

  describe 'not deleting guest user by default' do
    it { should_not contain_rabbitmq_user('guest') }
  end

  describe 'deleting guest user' do
    let :params do
      { :delete_guest_user => true }
    end
    it { should contain_rabbitmq_user('guest').with(
      'ensure'   => 'absent',
      'provider' => 'rabbitmqctl'
    ) }
  end

  describe 'specifing node_ip_address' do
    let :params do
      { :node_ip_address => '172.0.0.1' }
    end
    it 'should set RABBITMQ_NODE_IP_ADDRESS to specified value' do
      verify_contents(subject, 'rabbitmq-env.config',
        ['RABBITMQ_NODE_IP_ADDRESS=172.0.0.1'])
    end
  end

  describe 'not configuring stomp by default' do
    it 'should not specify stomp parameters in rabbitmq.config' do
      verify_contents(subject, 'rabbitmq.config',
        ['[','].'])
    end
  end

  describe 'configuring stomp' do
    let :params do
      { :config_stomp => true,
        :stomp_port   => 5679
      }
    end
    it 'should specify stomp port in rabbitmq.config' do
      verify_contents(subject, 'rabbitmq.config',
        ['[','{rabbitmq_stomp, [{tcp_listeners, [5679]} ]}','].'])
    end

  end

  describe 'configuring cluster' do
    let :params do
      { :config_cluster => true,
        :cluster_nodes => ['hare-1', 'hare-2'],
        :cluster_node_type => 'ram'
      }
    end
    it 'should specify cluster nodes and node type in rabbitmq.config' do
      verify_contents(subject, 'rabbitmq.config',
        ['[',"{rabbit, [{cluster_nodes, {['rabbit@hare-1', 'rabbit@hare-2'], ram}}]}", '].'])
    end
    it 'should have the default erlang cookie' do
      verify_contents(subject, 'erlang_cookie',
        ['EOKOWXQREETZSHFNTPEY'])
    end

  end

  describe 'specifying custom erlang cookie in cluster mode' do
    let :params do
      { :config_cluster => true,
        :erlang_cookie => 'YOKOWXQREETZSHFNTPEY' }
    end
    it 'should set .erlang.cookie to the specified value' do
      verify_contents(subject, 'erlang_cookie',
        ['YOKOWXQREETZSHFNTPEY'])
    end
  end

  describe 'configure mirrored queues in cluster mode' do
    let :params do
      { :config_cluster => true,
        :config_mirrored_queues => true
      }
    end
  end

end
