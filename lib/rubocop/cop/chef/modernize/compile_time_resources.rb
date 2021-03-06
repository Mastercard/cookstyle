# frozen_string_literal: true
#
# Copyright:: 2020, Chef Software, Inc.
# Author:: Tim Smith (<tsmith@chef.io>)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
module RuboCop
  module Cop
    module Chef
      module ChefModernize
        # The hostname, build_essential, chef_gem, and ohai_hint resources include 'compile_time' properties, which should be used to force the resources to run at compile time by setting `compile_time true`.
        #
        # @example
        #
        #   # bad
        #   build_essential 'install build tools' do
        #    action :nothing
        #   end.run_action(:install)
        #
        #   # good
        #   build_essential 'install build tools' do
        #    compile_time true
        #   end
        #
        class ResourceForcingCompileTime < Base
          MSG = "Set 'compile_time true' in resources when available instead of forcing resources to run at compile time by setting an action on the block."

          def_node_matcher :compile_time_resource?, <<-PATTERN
            (send (block (send nil? {:build_essential :chef_gem :hostname :ohai_hint} (...)) (args) (...)) $:run_action (sym ...))
          PATTERN

          def on_send(node)
            compile_time_resource?(node) do
              add_offense(node, message: MSG, severity: :refactor)
            end
          end
        end
      end
    end
  end
end
