require 'spec_helper'

module Codebreaker
  RSpec.describe Game do

    describe '#start' do
      it 'generates a secret code' do
        expect(subject.instance_variable_get(:@code)).not_to be_empty
      end
      it 'set status to :play' do
        expect(subject.status).to eq :play
      end
    end

    describe "#generate" do
      it 'sectet code with 4 numbers' do
        expect(subject.instance_variable_get(:@code).size).to eq 4
      end
      it 'secret code with numbers 1 to 6' do
        expect(subject.valid_code? subject.generate).to eq true
      end
      it 'different codes each time' do
        expect(subject.generate).not_to eq subject.generate
      end
    end

    describe '#game_over' do
      it 'return :lose with any args' do
        expect(subject.game_over).to eq :lose
      end
      it 'return :win with arg' do
        expect(subject.game_over true).to eq :win
      end
    end

    describe '#check_guess' do
      before {allow_any_instance_of(Game).to receive(:generate).and_return('1234')}
      variants = [
          [5555,''], [1555,'+'], [2555,'-'], [5254,'++'], [5154,'+-'],
          [2545,'--'], [5234,'+++'], [5134,'++-'], [5124,'+--'], [5123,'---'],
          [1234,:win], [1243,'++--'], [1423,'+---'], [4321,'----']
      ]

      variants.each do |variant|
        it "must return #{variant[1]} when guess = #{variant[0]}" do
          expect(subject.check variant[0]).to eq variant[1]
        end
      end

      it 'decrease attemps number' do
        expect {subject.check "1232"}.to change {subject.attempts}.by(-1)
      end
      it 'answer with lose if run out attempt' do
        allow(subject).to receive(:attempts).and_return(0)
        expect(subject.check "4444").to eq :lose
      end
    end

    describe '#hint' do
      it 'give one number' do
        expect(subject.hint.size).to eq 1
      end
      it 'contains in secret code' do
        expect(subject.instance_variable_get(:@code)).to include subject.hint
      end
    end

    describe "#save" do
      around do |example|
        DUMP_FILE ||= 'dump'
        SCORE_FILE_NAME ||= subject.default[:score_file_name]
        if File.exist? SCORE_FILE_NAME
          File.write(DUMP_FILE,File.read(SCORE_FILE_NAME))
        end
        example.run
        if File.exist? DUMP_FILE
          File.write(SCORE_FILE_NAME, File.read(DUMP_FILE))
          File.delete(DUMP_FILE)
        else
          File.delete SCORE_FILE_NAME if File.exist? SCORE_FILE_NAME
        end
      end
      it "shoud create file" do
        subject.instance_variable_set(:@name, 'test')
        subject.save
        expect(File.exist? SCORE_FILE_NAME).to eq true
      end
      it 'shoud change size by 1' do
        subject.instance_variable_set(:@name, 'test')
        expect {subject.save}.to change {File.read(SCORE_FILE_NAME).lines.count}.by(1)
      end
    end
  end
end