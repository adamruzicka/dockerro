module Dockerro
  class BuildResourcesController < ApplicationController

    before_filter :find_resource, :only => [:show, :edit, :associate, :update, :destroy]

    def index
      @build_resources = resource_base.search_for(params[:search], :order => params[:order]).paginate :page => params[:page]
    end

    def new
      @build_resource = ::Dockerro::BuildResource.new
    end

    def create
      @build_resource = ::Dockerro::BuildResource.new params[:build_resource]
      if @build_resource.save
        process_success :success_redirect => @build_resource
      else
        process_error
      end
    end

    def destroy
      fail NotImplementedError
    end

    def show
    end

    def edit
      require 'pry'; binding.pry
    end

    private

    def find_resource
      @build_resource = ::Dockerro::BuildResource.find(params[:id])
    end
  end
end