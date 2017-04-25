# Encoding: utf-8
# Cloud Foundry Java Buildpack
# Copyright 2013-2017 the original author or authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'java_buildpack/component/base_component'
require 'java_buildpack/container'
require 'java_buildpack/util/find_single_directory'
require 'java_buildpack/util/qualify_path'
require 'java_buildpack/util/start_script'

module JavaBuildpack
  module Container

    # Encapsulates the detect, compile, and release functionality for selecting a `distZip`-like container.
    class Standalone < JavaBuildpack::Component::BaseComponent
      include JavaBuildpack::Util

      # (see JavaBuildpack::Component::BaseComponent#detect)
      def detect
        supports? ? id : nil
      end

      # (see JavaBuildpack::Component::BaseComponent#compile)
      def compile
        standalone_path.chmod 0o755
      end

      # (see JavaBuildpack::Component::BaseComponent#release)
      def release
        [
          @droplet.environment_variables.as_env_vars,
          @droplet.java_home.as_env_var,
          @droplet.java_opts.as_env_var,
          'exec',
          qualify_path(standalone_path, @droplet.root)
        ].flatten.compact.join(' ')
      end

      protected

      # The id of this container
      #
      # @return [String] the id of this container
      def id
        Standalone.to_s.dash_case
      end

      # The root directory of the application
      #
      # @return [Pathname] the root directory of the application
      def root
        @application.root
      end

      # Whether or not this component supports this application
      #
      # @return [Boolean] whether or not this component supports this application
      def supports?
        standalone_path.exist?
      end

      def standalone_path
        Pathname.new("#{root}/bin/standalone.sh")
      end

    end
  end
end
