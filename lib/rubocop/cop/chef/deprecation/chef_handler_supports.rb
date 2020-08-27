# frozen_string_literal: true
#
# Copyright:: 2019-2020, Chef Software, Inc.
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
      module ChefDeprecations
        # Use the type property instead of the deprecated supports property in the chef_handler resource. The supports property was removed in chef_handler cookbook version 3.0 (June 2017) and Chef Infra Client 14.0.
        #
        # @example
        #
        #   # bad
        #   chef_handler 'whatever' do
        #     supports start: true, report: true, exception: true
        #   end0
        #
        #   # good
        #   chef_handler 'whatever' do
        #     type start: true, report: true, exception: true
        #   end
        #
        class ChefHandlerUsesSupports < Base
          include RuboCop::Chef::CookbookHelpers
          extend AutoCorrector

          MSG = 'Use the type property instead of the deprecated supports property in the chef_handler resource. The supports property was removed in chef_handler cookbook version 3.0 (June 2017) and Chef Infra Client 14.0.'

          def on_block(node)
            match_property_in_resource?(:chef_handler, 'supports', node) do |prop_node|
              add_offense(prop_node, message: MSG, severity: :warning) do |corrector|
                # make sure to delete leading and trailing {}s that would create invalid ruby syntax
                extracted_val = prop_node.arguments.first.source.gsub(/{|}/, '')
                corrector.replace(prop_node.loc.expression, "type #{extracted_val}")
              end
            end
          end
        end
      end
    end
  end
end
