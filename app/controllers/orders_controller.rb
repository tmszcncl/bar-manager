class OrdersController < ApplicationController
  before_action :set_order, only: [:show, :edit, :update, :destroy]

  def index
    @orders = Order.all
  end

  def new
    @order = Order.new(step: Order::STEPS.first)
    3.times { @order.order_items.build(quantity: 0) }
  end

  def edit
    3.times { @order.order_items.build(quantity: 0) }
  end

  def create
    @order = Order.new(order_params)
    @order.remove_invalid_order_items
    if params[:add_new_item]
      @order.save
      redirect_to edit_order_path(@order)
    end
    if params[:commit] == 'Transfer to Kitchen'
      @order.step = 'queued'
      @order.save
      ActionCable.server.broadcast 'notification_channel', info: 'Order sent to Kitchen'
      redirect_to new_order_path
    end
  end

  def queued
    @orders = Order.where(step: 'queued')
  end

  def update
    @order.remove_invalid_order_items
    remove_zombie_order_items
    new_order_params = order_params.dup
    new_order_params['order_items_attributes'].delete_if do |_, v|
      v['quantity'].to_i.zero? || v['product_id'].to_i.zero?
    end
    if params[:add_new_item]
      @order.update(new_order_params)
      redirect_to edit_order_path(@order)
    end
    if params[:commit] == 'Transfer to Kitchen'
      @order.step = 'queued'
      @order.update(new_order_params)
      redirect_to new_order_path
    end
  end

  def destroy
    @order.destroy
    respond_to do |format|
      format.html { redirect_to orders_url, notice: 'Order was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_order
    @order = Order.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def order_params
    params.require(:order).permit(:step, order_items_attributes: [:id, :product_id, :order_id, :quantity])
  end

  def remove_zombie_order_items
    atts = order_params['order_items_attributes']
    zombies = atts.select { |_, v| v['quantity'].to_i.zero? && !v['product_id'].blank? }
    if zombies
      zombies = zombies.map { |_, v| v[:id] }
      zombies.each { |z| OrderItem.find(z).delete }
    end
  end
end
